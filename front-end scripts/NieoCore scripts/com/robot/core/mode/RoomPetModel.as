package com.robot.core.mode
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.MovesLangXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.NonoManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MathUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class RoomPetModel extends BobyModel
   {
      
      private var _info:PetListInfo;
      
      private var _obj:MovieClip;
      
      private var _inTime:uint;
      
      private var _dialogTime:uint;
      
      public function RoomPetModel(param1:PetListInfo)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         _speed = 2;
         this._info = param1;
      }
      
      override public function get width() : Number
      {
         if(Boolean(this._obj))
         {
            return this._obj.width;
         }
         return super.width;
      }
      
      override public function get height() : Number
      {
         if(Boolean(this._obj))
         {
            return this._obj.height;
         }
         return super.height;
      }
      
      public function get info() : PetListInfo
      {
         return this._info;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(Boolean(this._obj))
         {
            this._obj.gotoAndStop(param1);
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
         _hitRect.x = x - this.width / 2;
         _hitRect.y = y - this.height;
         _hitRect.width = this.width;
         _hitRect.height = this.height;
         return _hitRect;
      }
      
      public function show(param1:Point) : void
      {
         if(Boolean(this._obj))
         {
            return;
         }
         pos = param1;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this.info.skinID != 0 ? this.info.skinID : uint(this.info.id)),this.onLoad,"pet");
      }
      
      override public function destroy() : void
      {
         clearInterval(this._dialogTime);
         super.destroy();
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
         ResourceManager.cancel(ClientConfig.getPetSwfPath(this.info.skinID != 0 ? this.info.skinID : uint(this.info.id)),this.onLoad);
         DisplayUtil.removeForParent(this);
         this._obj = null;
      }
      
      override public function aimatState(param1:AimatInfo) : void
      {
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         this._obj.gotoAndStop(_direction);
         addChild(this._obj);
         MapManager.currentMap.depthLevel.addChild(this);
         starAutoWalk(2000);
         MovieClipUtil.childStop(this._obj,1);
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
         if(Boolean(NonoManager.info))
         {
            if(Boolean(NonoManager.info.func[9]))
            {
               clearInterval(this._dialogTime);
               this._dialogTime = setInterval(this.onAutoDialog,MathUtil.randomHalfAdd(20000));
            }
         }
      }
      
      private function onAutoDialog() : void
      {
         var _loc1_:String = MovesLangXMLInfo.getRandomLang(this._info.id);
         if(_loc1_ != "")
         {
            showBox(_loc1_);
         }
      }
      
      private function onWalkStart(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(this._obj))
         {
            _loc2_ = this._obj.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               if(_loc2_.currentFrame == 1)
               {
                  _loc2_.gotoAndPlay(2);
               }
            }
         }
      }
      
      private function onWalkOver(param1:Event) : void
      {
         if(Boolean(this._obj))
         {
            MovieClipUtil.childStop(this._obj,1);
         }
      }
   }
}

