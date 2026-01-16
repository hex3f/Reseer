package com.robot.app.mapProcess.active.randomPet
{
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.taomee.utils.MovieClipUtil;
   
   public class RunPet extends NormalPet implements IRandomPet
   {
      
      private var runTimer:Timer;
      
      private var clickTimer:Timer;
      
      public function RunPet()
      {
         super();
         this.speed = 8;
         this.clickTimer = new Timer(30 * 1000,1);
         this.clickTimer.addEventListener(TimerEvent.TIMER,this.onClickTimer);
         this.clickTimer.start();
         this.mouseEnabled = false;
         this.mouseChildren = false;
      }
      
      override public function show(param1:uint) : void
      {
         super.show(param1);
         this.addEvent();
         this.runTimer = new Timer(1000);
         this.runTimer.addEventListener(TimerEvent.TIMER,this.go);
         this.runTimer.start();
      }
      
      private function go(param1:TimerEvent) : void
      {
         _walk.execute(this,new Point(Math.random() * MainManager.getStageWidth(),Math.random() * MainManager.getStageHeight()),false);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEvent();
         this.runTimer.stop();
         this.runTimer.removeEventListener(TimerEvent.TIMER,this.go);
         this.runTimer = null;
         this.clickTimer.stop();
         this.clickTimer.removeEventListener(TimerEvent.TIMER,this.onClickTimer);
         this.clickTimer = null;
      }
      
      override public function set direction(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         _direction = param1;
         _petMc.gotoAndStop(_direction);
      }
      
      private function addEvent() : void
      {
         addEventListener(RobotEvent.WALK_START,this.onWalkStart);
         addEventListener(RobotEvent.WALK_END,this.onWalkOver);
      }
      
      private function removeEvent() : void
      {
         removeEventListener(RobotEvent.WALK_START,this.onWalkStart);
         removeEventListener(RobotEvent.WALK_END,this.onWalkOver);
      }
      
      private function onWalkStart(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(Boolean(_petMc))
         {
            _loc2_ = _petMc.getChildAt(0) as MovieClip;
            if(Boolean(_loc2_))
            {
               if(_loc2_.currentFrame == 1)
               {
                  _loc2_.gotoAndPlay(2);
               }
            }
         }
      }
      
      private function onClickTimer(param1:TimerEvent) : void
      {
         this.mouseChildren = true;
      }
      
      private function onWalkOver(param1:Event) : void
      {
         if(Boolean(_petMc))
         {
            MovieClipUtil.childStop(_petMc,1);
         }
      }
   }
}

