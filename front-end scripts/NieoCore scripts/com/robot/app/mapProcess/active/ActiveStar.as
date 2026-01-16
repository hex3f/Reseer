package com.robot.app.mapProcess.active
{
   import com.robot.core.*;
   import com.robot.core.info.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import flash.events.*;
   import flash.geom.Point;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   
   public class ActiveStar
   {
      
      private var start:Point;
      
      private var end:Point;
      
      private var timer:Timer;
      
      public function ActiveStar(param1:Point, param2:Point)
      {
         var start:Point = param1;
         var end:Point = param2;
         super();
         this.start = start;
         this.end = end;
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,arguments.callee);
            var _loc3_:Date = (param1.data as SystemTimeInfo).date;
            if(_loc3_.getDate() >= 24)
            {
               timer = new Timer(500);
               timer.addEventListener(TimerEvent.TIMER,onTimer);
               timer.start();
            }
         });
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Star = null;
         _loc2_ = null;
         var _loc3_:Number = this.start.x + Math.random() * (this.end.x - this.end.y);
         _loc2_ = new Star();
         _loc2_.x = _loc3_;
         _loc2_.y = -10;
         MapManager.currentMap.animatorLevel["mc"].addChild(_loc2_);
      }
      
      public function destroy() : void
      {
         if(Boolean(this.timer))
         {
            this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.timer.stop();
            this.timer = null;
         }
      }
   }
}

import com.robot.core.manager.MainManager;
import com.robot.core.manager.map.MapLibManager;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;

class Star extends Sprite
{
   
   private var mc:MovieClip;
   
   public function Star()
   {
      super();
      this.mc = MapLibManager.getMovieClip("star");
      if(!this.mc)
      {
         return;
      }
      addChild(this.mc);
      this.mc.alpha = 0.8;
      this.mc.scaleY = 0.8;
      this.mc.scaleX = 0.8;
      this.addEventListener(Event.ENTER_FRAME,this.onEnter);
   }
   
   private function onEnter(param1:Event) : void
   {
      var _loc2_:uint = Math.floor(Math.random() * 4) + 8;
      this.mc.x += _loc2_ * 1.3;
      this.mc.y += _loc2_;
      if(this.mc.x > MainManager.getStageWidth() || this.mc.y > MainManager.getStageHeight())
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnter);
         this.mc = null;
      }
   }
}
