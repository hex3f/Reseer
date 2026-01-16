package com.robot.app.mapProcess.active
{
   import com.robot.core.event.*;
   import com.robot.core.manager.*;
   import com.robot.core.mode.ActionSpriteModel;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import org.taomee.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class ActiveBigFootOgre extends ActionSpriteModel
   {
      
      public static const ESCAPE_SUCCESS:String = "escape_success";
      
      private var _obj:MovieClip;
      
      private var _path:Array = [new Point(65,300),new Point(160,200),new Point(318,168)];
      
      private var _bEscape:Boolean = false;
      
      private var _hasEscape:Boolean = true;
      
      public function ActiveBigFootOgre()
      {
         super();
         this.x = 445;
         this.y = 362;
         speed = 2;
         ResourceManager.getResource("resource/bounsMovie/bigfootogre.swf",this.onLoad,"pet");
      }
      
      private function checkDis(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Point = MainManager.actorModel.localToGlobal(new Point());
         var _loc4_:Point = this.localToGlobal(new Point());
         _loc2_ = Point.distance(_loc3_,_loc4_);
         if(_loc2_ < 100)
         {
            this.removeEventListener(Event.ENTER_FRAME,this.checkDis);
            speed = 6;
            this._hasEscape = false;
         }
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         this._obj.gotoAndStop(_direction);
         addChild(this._obj);
         MapManager.currentMap.depthLevel.addChild(this);
         this.addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         this.addEventListener(RobotEvent.WALK_END,this.onWalkOver);
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
      
      public function startWalk() : void
      {
         this.addEventListener(Event.ENTER_FRAME,this.checkDis);
         _walk.execute_point(this,this.nextPoint(),false);
         this._bEscape = true;
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
         if(this._path.length == 1)
         {
            this.removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
            this.removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
            if(this._hasEscape)
            {
               this._obj.gotoAndStop("watch");
               setTimeout(this.destroy,2500);
            }
            else
            {
               this.destroy();
            }
            EventManager.dispatchEvent(new DynamicEvent(ESCAPE_SUCCESS,this._hasEscape));
            return;
         }
         this._obj.gotoAndStop("watch");
         setTimeout(this.walkToNext,2500);
      }
      
      private function walkToNext() : void
      {
         _walk.execute_point(this,this.nextPoint(),false);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         DisplayUtil.removeForParent(this._obj);
         this._obj = null;
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
         removeEventListener(Event.ENTER_FRAME,this.checkDis);
      }
      
      private function nextPoint() : Point
      {
         if(this._bEscape)
         {
            this._path.splice(0,1);
         }
         return this._path[0];
      }
   }
}

