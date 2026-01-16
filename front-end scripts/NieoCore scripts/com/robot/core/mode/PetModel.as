package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.pet.PetInfoController;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class PetModel extends ActionSpriteModel
   {
      
      public static const MAX:int = 40;
      
      private var _people:ActionSpriteModel;
      
      private var _petMc:MovieClip;
      
      private var _info:PetShowInfo;
      
      private var _petLight:MovieClip;
      
      public function PetModel(param1:ActionSpriteModel)
      {
         super();
         _speed = 3;
         this._people = param1;
         buttonMode = true;
      }
      
      public function get info() : PetShowInfo
      {
         return this._info;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(Boolean(this._petMc))
         {
            this._petMc.gotoAndStop(param1);
         }
      }
      
      public function setVisible(param1:Boolean) : void
      {
         if(Boolean(this._petMc))
         {
            this._petMc.visible = param1;
         }
      }
      
      override public function get centerPoint() : Point
      {
         _centerPoint.x = x;
         _centerPoint.y = y - 10;
         return _centerPoint;
      }
      
      override public function get hitRect() : Rectangle
      {
         _hitRect.x = x - width / 2;
         _hitRect.y = y - height;
         _hitRect.width = width;
         _hitRect.height = height;
         return _hitRect;
      }
      
      public function show(param1:PetShowInfo) : void
      {
         this._info = param1;
         x = this._people.x + 40;
         y = this._people.y + 5;
         MapManager.currentMap.depthLevel.addChild(this);
         this.addEvent();
         if(Boolean(this._petMc))
         {
            this.bright();
            if(param1.userID != MainManager.actorInfo.userID && !UserManager.isShow)
            {
               this.visible = false;
            }
            else
            {
               this.visible = true;
            }
            return;
         }
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this.info.skinID != 0 ? uint(this.info.skinID) : uint(this.info.petID)),this.onLoad,"pet");
      }
      
      public function hide() : void
      {
         this.removeEvent();
         if(Boolean(this._petMc))
         {
            DisplayUtil.removeForParent(this._petMc);
            this._petMc = null;
         }
         if(PetXMLInfo.isFlyPet(this.info.petID) || PetXMLInfo.isRidePet(this.info.petID))
         {
            ResourceManager.cancelURL(ClientConfig.getFlyPetSwfPath(this.info.petID));
         }
         else
         {
            ResourceManager.cancelURL(ClientConfig.getPetSwfPath(this.info.skinID != 0 ? uint(this.info.skinID) : uint(this.info.petID)));
         }
         DisplayUtil.removeForParent(this);
      }
      
      public function bright() : void
      {
         this.removeBright();
         if(this.info.dv == 31 && Boolean(this._petMc))
         {
            this._petLight = UIManager.getMovieClip("PetBright_MC");
            this._petMc.addChildAt(this._petLight,0);
         }
      }
      
      public function removeBright() : void
      {
         if(Boolean(this._petLight))
         {
            DisplayUtil.removeForParent(this._petLight);
            this._petLight = null;
         }
      }
      
      public function walkAction(param1:Object) : void
      {
         if(this._people == null)
         {
            return;
         }
         _walk.execute(this,param1,false);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.hide();
         this._people = null;
         if(Boolean(this._petMc))
         {
            this._petMc = null;
         }
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         if(this._people == null)
         {
            return;
         }
         this._petMc = param1 as MovieClip;
         MovieClipUtil.childStop(this._petMc,1);
         this.direction = this._people.direction;
         addChild(this._petMc);
         this.bright();
         if(_walk.isPlaying)
         {
            this.onWalkStart(null);
         }
         if(this.info.userID != MainManager.actorInfo.userID && !UserManager.isShow)
         {
            this.visible = false;
         }
         else
         {
            this.visible = true;
         }
      }
      
      private function addEvent() : void
      {
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
         addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterFrame);
         this._people.addEventListener(RobotEvent.WALK_START,this.onPeopleWalkStart);
         if(this._people.walk.isPlaying)
         {
            this._people.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onPeopleWalkEnter);
         }
         addEventListener(MouseEvent.CLICK,this.onPetClickHandler);
      }
      
      private function removeEvent() : void
      {
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
         removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEnterFrame);
         this._people.removeEventListener(RobotEvent.WALK_START,this.onPeopleWalkStart);
         this._people.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onPeopleWalkEnter);
         removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
      }
      
      private function onWalkStart(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(this._petMc))
         {
            _loc2_ = this._petMc.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               if(_loc2_.currentFrame == 1)
               {
                  _loc2_.gotoAndPlay(2);
               }
            }
         }
      }
      
      private function onWalkEnterFrame(param1:Event) : void
      {
         if(Point.distance(pos,_walk.endP) < MAX)
         {
            stop();
         }
      }
      
      private function onWalkOver(param1:Event) : void
      {
         if(Boolean(this._petMc))
         {
            MovieClipUtil.childStop(this._petMc,1);
         }
      }
      
      private function onPetClickHandler(param1:MouseEvent) : void
      {
         PetInfoController.getInfo(false,this._info.userID,this._info.catchTime);
      }
      
      private function onPeopleWalkStart(param1:Event) : void
      {
         this._people.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onPeopleWalkEnter);
      }
      
      private function onPeopleWalkEnter(param1:Event) : void
      {
         var _loc2_:Array = null;
         if(Boolean(this._petMc))
         {
            if(Point.distance(pos,this._people.pos) > MAX)
            {
               if(Point.distance(pos,this._people.walk.endP) > Point.distance(this._people.pos,this._people.walk.endP))
               {
                  _loc2_ = this._people.walk.remData;
                  _loc2_.unshift(this._people.pos);
                  _loc2_.unshift(pos);
                  this.walkAction(_loc2_);
                  this._people.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onPeopleWalkEnter);
               }
            }
         }
      }
   }
}

