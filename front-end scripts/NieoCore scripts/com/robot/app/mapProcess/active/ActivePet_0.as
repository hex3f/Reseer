package com.robot.app.mapProcess.active
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.ActionSpriteModel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.taomee.manager.ResourceManager;
   
   public class ActivePet_0 extends ActionSpriteModel
   {
      
      private var _obj:MovieClip;
      
      private var isWalking:Boolean = false;
      
      private var isEscape:Boolean = false;
      
      private var left:PointList;
      
      private var right:PointList;
      
      private var currentPointList:PointList;
      
      private var isCanMove:Boolean = true;
      
      private var timer:Timer;
      
      private var isRightFill:Boolean = false;
      
      private var isLeftFill:Boolean = false;
      
      public function ActivePet_0(param1:uint)
      {
         super();
         speed = 2;
         this.visible = false;
         addEventListener(Event.ENTER_FRAME,this.checkDis);
         this.left = new PointList([new Point(288,188),new Point(420,240),new Point(430,350),new Point(760,360)]);
         this.right = new PointList([new Point(760,360),new Point(430,350),new Point(420,240),new Point(288,188)]);
         this.currentPointList = this.left;
         this.x = this.left.first().x;
         this.y = this.left.first().y;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1),this.onLoad,"pet");
      }
      
      public function catchPet() : Boolean
      {
         var _loc1_:Point = new Point(595,338);
         var _loc2_:Point = this.localToGlobal(new Point());
         var _loc3_:Number = Point.distance(_loc1_,_loc2_);
         return _loc3_ < 60;
      }
      
      private function checkDis(param1:Event) : void
      {
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         this._obj.gotoAndStop(_direction);
         addChild(this._obj);
         MapManager.currentMap.depthLevel.addChild(this);
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
         this.startWalk();
         this.isWalking = true;
      }
      
      private function startWalk() : void
      {
         this.visible = true;
         _walk.execute_point(this,this.currentPointList.next());
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
         var _loc2_:Point = this.currentPointList.next();
         if(_loc2_ == this.currentPointList.first())
         {
            if(this.currentPointList == this.left)
            {
               this.currentPointList = this.right;
            }
            else
            {
               this.currentPointList = this.left;
            }
            this.currentPointList.reset();
         }
         _walk.execute_point(this,_loc2_);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
         removeEventListener(Event.ENTER_FRAME,this.checkDis);
      }
   }
}

import flash.geom.Point;

class PointList
{
   
   private var array:Array = [];
   
   private var index:uint = 0;
   
   public function PointList(param1:Array)
   {
      super();
      this.array = param1.slice();
   }
   
   public function first() : Point
   {
      return this.array[0];
   }
   
   public function next() : Point
   {
      if(this.index < this.array.length - 1)
      {
         ++this.index;
      }
      else
      {
         this.index = 0;
      }
      return this.array[this.index];
   }
   
   public function reset() : void
   {
      this.index = 0;
   }
   
   public function end() : Point
   {
      return this.array[this.array.length - 1];
   }
   
   public function setToEnd() : void
   {
      this.index = this.array.length - 1;
   }
}
