package com.robot.core.mode
{
   import com.robot.core.aticon.PeculiarAction;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.pet.PetInfoController;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class FlyPetModel extends PetModel
   {
      
      private var _people:ActionSpriteModel;
      
      private var _info:PetShowInfo;
      
      private var _petId:uint;
      
      private var _flyPetMc:MovieClip;
      
      private var _pe:PeculiarAction;
      
      private var _skele:EmptySkeletonStrategy;
      
      private var _isMyself:Boolean = false;
      
      private var _brightMc:MovieClip;
      
      public function FlyPetModel(param1:ActionSpriteModel)
      {
         super(param1);
         this._people = param1;
         this._isMyself = (this._people as BasePeoleModel).info.userID == MainManager.actorID ? true : false;
      }
      
      override public function get info() : PetShowInfo
      {
         return this._info;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(Boolean(this._flyPetMc))
         {
            this._flyPetMc.gotoAndStop(param1);
         }
         if(Boolean(this._skele))
         {
            this._skele.getBodyMC()["color"].gotoAndStop(param1);
         }
      }
      
      private function toDown() : void
      {
         var t:uint = 0;
         t = 0;
         this._skele = (this._people as BasePeoleModel).skeleton as EmptySkeletonStrategy;
         this._pe = new PeculiarAction();
         this._pe.keepUp(this._skele,PetXMLInfo.flyPetY(this._info.petID));
         t = setTimeout(function():void
         {
            var _loc1_:* = undefined;
            if(_isMyself)
            {
               _loc1_ = PetXMLInfo.petScale(_info.petID);
               (_people as ActorModel).footMC.scaleX = (_people as ActorModel).footMC.scaleY = _loc1_;
            }
            if(Boolean(_people) && Boolean(_skele))
            {
               _flyPetMc["pMc"].addChild(_skele.getBodyMC());
               _people.sprite.addChildAt(_flyPetMc,3);
            }
            clearTimeout(t);
         },200);
      }
      
      private function onWalkEndHandler(param1:RobotEvent) : void
      {
         this.addEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
         this.removeEventListener(Event.ENTER_FRAME,this.onStartEnterHandler);
      }
      
      private function onWalkStartHandler(param1:RobotEvent) : void
      {
         this.removeEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
         this.addEventListener(Event.ENTER_FRAME,this.onStartEnterHandler);
      }
      
      private function onEndEnterHandler(param1:Event) : void
      {
         if(this._flyPetMc == null)
         {
            this.removeEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
            return;
         }
         var _loc2_:MovieClip = this._flyPetMc.getChildByName("head") as MovieClip;
         if(Boolean(_loc2_))
         {
            _loc2_.gotoAndStop(_loc2_.totalFrames);
         }
         var _loc3_:MovieClip = this._flyPetMc.getChildByName("mc") as MovieClip;
         if(Boolean(_loc3_))
         {
            this.removeEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
            _loc3_.gotoAndStop(_loc3_.totalFrames);
         }
      }
      
      private function onStartEnterHandler(param1:Event) : void
      {
         if(this._flyPetMc == null)
         {
            this.removeEventListener(Event.ENTER_FRAME,this.onStartEnterHandler);
            return;
         }
         var _loc2_:MovieClip = this._flyPetMc.getChildByName("head") as MovieClip;
         if(Boolean(_loc2_))
         {
            _loc2_.gotoAndPlay(1);
         }
         var _loc3_:MovieClip = this._flyPetMc.getChildByName("mc") as MovieClip;
         if(Boolean(_loc3_))
         {
            this.removeEventListener(Event.ENTER_FRAME,this.onStartEnterHandler);
            _loc3_.gotoAndPlay(1);
         }
      }
      
      override public function show(param1:PetShowInfo) : void
      {
         if(this._people == null)
         {
            return;
         }
         this._info = param1;
         this._petId = this._info.petID;
         this._people.speed = PetXMLInfo.flyPetSpeed(this._info.petID) + 5;
         this.buttonMode = true;
         this.addEvent();
         if(!this._flyPetMc)
         {
            ResourceManager.getResource(ClientConfig.getFlyPetSwfPath(this._petId),this.onLoad,"pet");
         }
         else
         {
            this.showLight();
            if(this.info.userID != MainManager.actorInfo.userID && !UserManager.isShow)
            {
               this.visible = false;
            }
            else
            {
               this.visible = true;
            }
         }
      }
      
      override public function bright() : void
      {
         this.removeBright();
         this._brightMc = UIManager.getMovieClip("PetBright_MC");
         this._flyPetMc.addChildAt(this._brightMc,0);
      }
      
      public function showLight() : void
      {
         if(this._info.dv == 31)
         {
            this.bright();
         }
         else
         {
            removeBright();
         }
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         if(this._people == null)
         {
            return;
         }
         this._flyPetMc = param1 as MovieClip;
         this.direction = this._people.direction;
         this.toDown();
         this.showLight();
         this.addEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
      }
      
      private function addEvent() : void
      {
         this._people.addEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
         this._people.addEventListener(RobotEvent.WALK_END,this.onWalkEndHandler);
         this._people.addEventListener(RobotEvent.WALK_START,this.onWalkStartHandler);
         addEventListener(MouseEvent.CLICK,this.onPetClickHandler);
      }
      
      private function removeEvent() : void
      {
         this._people.removeEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
         this._people.removeEventListener(RobotEvent.WALK_END,this.onWalkEndHandler);
         this._people.removeEventListener(RobotEvent.WALK_START,this.onWalkStartHandler);
         this.removeEventListener(Event.ENTER_FRAME,this.onEndEnterHandler);
         this.removeEventListener(Event.ENTER_FRAME,this.onStartEnterHandler);
         removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
      }
      
      private function onPetClickHandler(param1:MouseEvent) : void
      {
         PetInfoController.getInfo(false,this._info.userID,this._info.catchTime);
      }
      
      private function onChangeDirHandler(param1:DynamicEvent) : void
      {
         this.direction = param1.paramObject as String;
      }
      
      override public function hide() : void
      {
         this.removeEvent();
         super.hide();
      }
      
      override public function destroy() : void
      {
         if(Boolean(this._skele))
         {
            (this._people as BasePeoleModel).sprite.addChildAt(this._skele.getBodyMC(),3);
         }
         if(this._isMyself)
         {
            (this._people as ActorModel).footMC.scaleX = (this._people as ActorModel).footMC.scaleY = 1;
         }
         this.hide();
         removeBright();
         this._people.speed = ItemXMLInfo.getSpeed(MainManager.actorInfo.clothIDs);
         new PeculiarAction().standUp((this._people as BasePeoleModel).skeleton as EmptySkeletonStrategy);
         if(this._petId != 0)
         {
            ResourceManager.cancel(ClientConfig.getFlyPetSwfPath(this._petId),this.onLoad);
         }
         if(Boolean(this._flyPetMc))
         {
            DisplayUtil.stopAllMovieClip(this._flyPetMc);
            DisplayUtil.removeForParent(this._flyPetMc);
         }
         super.destroy();
         this._info = null;
         this._people = null;
         this._flyPetMc = null;
      }
   }
}

