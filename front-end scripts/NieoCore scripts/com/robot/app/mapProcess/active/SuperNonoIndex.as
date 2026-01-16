package com.robot.app.mapProcess.active
{
   import com.robot.core.ui.DialogBox;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.manager.ToolTipManager;
   
   public class SuperNonoIndex
   {
      
      public static var _timer1:Timer;
      
      private static var boxMc:MovieClip;
      
      private static var _talkStr:String = "我是超能指引，有什么需要我帮忙的吗？";
      
      public function SuperNonoIndex()
      {
         super();
      }
      
      public static function superIndx(param1:MovieClip) : void
      {
         param1.buttonMode = true;
         boxMc = param1;
         ToolTipManager.add(param1,"侠客的超能指引");
         showBox();
         startTime();
      }
      
      private static function showBox() : void
      {
         var _loc1_:DialogBox = new DialogBox();
         _loc1_.show(_talkStr,25,5,boxMc);
      }
      
      private static function startTime() : void
      {
         _timer1 = new Timer(8000);
         _timer1.addEventListener(TimerEvent.TIMER,onTimerHandler);
         _timer1.start();
      }
      
      private static function onTimerHandler(param1:TimerEvent) : void
      {
         showBox();
      }
   }
}

