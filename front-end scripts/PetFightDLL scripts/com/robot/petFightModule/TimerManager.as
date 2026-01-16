package com.robot.petFightModule
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.petFightModule.ui.controlPanel.IAutoActionPanel;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class TimerManager
   {
      
      private static var timer:Timer;
      
      public static var autoAction:IAutoActionPanel;
      
      private static var txt:TextField;
      
      private static var autoTimer:Timer;
      
      private static const TIME_COUNT:uint = 10;
      
      private static var timeCount:uint = TIME_COUNT;
      
      public function TimerManager()
      {
         super();
      }
      
      public static function clearTxt() : void
      {
         timeCount = TIME_COUNT;
         timer.reset();
         timer.stop();
         txt.text = "";
      }
      
      private static function onTimerHandler(param1:TimerEvent) : void
      {
         if(timer.currentCount == TIME_COUNT)
         {
            timeCount = TIME_COUNT;
            autoAction.auto();
            return;
         }
         if(timeCount > 0)
         {
            --timeCount;
         }
         txt.text = timeCount.toString();
      }
      
      public static function start() : void
      {
         timer.stop();
         timer.reset();
         timeCount = TIME_COUNT;
         timer.start();
         autoTimer.stop();
         autoTimer.start();
      }
      
      public static function setup(param1:TextField) : void
      {
         txt = param1;
         timer = new Timer(1000,TIME_COUNT);
         timer.addEventListener(TimerEvent.TIMER,onTimerHandler);
         autoTimer = new Timer(2000,1);
         autoTimer.addEventListener(TimerEvent.TIMER,onAutoTimer);
      }
      
      private static function onAutoTimer(param1:TimerEvent) : void
      {
         if(Boolean(AutomaticFightManager.isStart) && Boolean(PetFightEntry.isCanAuto))
         {
            autoAction.auto();
         }
      }
      
      public static function stop() : void
      {
         timer.reset();
         timer.stop();
         timeCount = TIME_COUNT;
      }
      
      public static function wait() : void
      {
         timer.reset();
         timer.stop();
         txt.text = "等待对方";
         timeCount = TIME_COUNT;
      }
   }
}

