package com.robot.app.protectSys
{
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.info.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   
   public class ProtectSystem
   {
      
      private static var mc:MovieClip;
      
      private static var timer:Timer;
      
      private static var timer2:Timer;
      
      private static var leftTime:int;
      
      private static var total:uint;
      
      private static var timer_45:Timer;
      
      private static var bgMC:MovieClip;
      
      private static var isHoliday:Boolean = false;
      
      public static var canShow:Boolean = true;
      
      private static var remainingTime:uint = 3600;
      
      public function ProtectSystem()
      {
         super();
      }
      
      private static function setup() : void
      {
         SocketConnection.addCmdListener(CommandID.SYNC_TIME,onSyncTime);
         total = MainManager.actorInfo.timeLimit;
         leftTime = total - MainManager.actorInfo.timeToday;
         checkTime();
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,onSysTime);
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private static function onSyncTime(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         leftTime = total - _loc3_;
         checkTime();
      }
      
      public static function start(param1:MovieClip) : void
      {
         mc = param1;
         mc["bgMC"].gotoAndStop(1);
         setup();
      }
      
      private static function checkTime() : void
      {
         if(leftTime < 0)
         {
            leftTime = 0;
         }
         if(total - leftTime < 2 * 60 * 60)
         {
            mc["bgMC"].gotoAndStop(1);
         }
         else
         {
            mc["bgMC"].gotoAndStop(2);
         }
         if(!timer)
         {
            timer = new Timer(60 * 1000);
            timer.addEventListener(TimerEvent.TIMER,timerHandler);
         }
         if(leftTime > 60)
         {
            timer.start();
         }
         else
         {
            timer.stop();
            showSecond();
         }
         var _loc1_:String = getHours();
         var _loc2_:String = getMin();
         mc["timeTxt"].text = _loc1_ + ":" + _loc2_;
         resetBar();
         if(!timer_45)
         {
            timer_45 = new Timer(45 * 60 * 1000);
            timer_45.addEventListener(TimerEvent.TIMER,timerHandler45);
         }
         if(leftTime > 0)
         {
            timer_45.start();
         }
      }
      
      private static function timerHandler(param1:TimerEvent) : void
      {
         leftTime -= 60;
         if(leftTime <= 60)
         {
            showSecond();
            timer.stop();
            timer.removeEventListener(TimerEvent.TIMER,timerHandler);
            return;
         }
         resetBar();
         var _loc2_:String = getHours();
         var _loc3_:String = getMin();
         mc["timeTxt"].text = _loc2_ + ":" + _loc3_;
      }
      
      private static function resetBar() : void
      {
         var _loc2_:uint = 0;
         var _loc1_:uint = uint(Math.ceil(4 * (leftTime / total)));
         while(_loc2_ < 4)
         {
            mc["bar_" + _loc2_].visible = false;
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            mc["bar_" + _loc2_].visible = true;
            _loc2_++;
         }
      }
      
      private static function showSecond() : void
      {
         if(!timer2)
         {
            timer2 = new Timer(1000);
            timer2.addEventListener(TimerEvent.TIMER,secondTimerHandler);
            timer2.start();
         }
      }
      
      private static function secondTimerHandler(param1:TimerEvent) : void
      {
         --leftTime;
         var _loc2_:String = leftTime.toString();
         if(_loc2_.length < 2)
         {
            _loc2_ = "0" + _loc2_;
         }
         if(leftTime < 0)
         {
            mc["timeTxt"].text = "00:00";
         }
         else
         {
            mc["timeTxt"].text = "00:" + _loc2_;
         }
         if(leftTime <= 0)
         {
            mc["bgMC"].gotoAndStop(2);
            mc["timeTxt"].text = "00:00";
            Alarm.show("精灵包电量耗尽，所有精灵进入休眠状态。明天电量就可以恢复，你就可以重新训练精灵了");
            timer2.stop();
            timer2.removeEventListener(TimerEvent.TIMER,secondTimerHandler);
            SocketConnection.removeCmdListener(CommandID.SYNC_TIME,onSyncTime);
         }
      }
      
      private static function getHours() : String
      {
         var _loc1_:String = Math.floor(leftTime / 60 / 60).toString();
         if(_loc1_.length < 2)
         {
            _loc1_ = "0" + _loc1_;
         }
         return _loc1_;
      }
      
      private static function getMin() : String
      {
         var _loc1_:uint = uint(getHours()) * 60 * 60;
         var _loc2_:uint = uint(leftTime - _loc1_);
         var _loc3_:uint = uint(Math.ceil(_loc2_ / 60));
         if(_loc3_ == 60)
         {
            _loc3_ = 59;
         }
         var _loc4_:String = _loc3_.toString();
         if(_loc4_.length < 2)
         {
            _loc4_ = "0" + _loc4_;
         }
         return _loc4_;
      }
      
      private static function onSysTime(param1:SocketEvent) : void
      {
         var _loc2_:Date = (param1.data as SystemTimeInfo).date;
         isHoliday = _loc2_.getDay() > 4 || _loc2_.getDay() == 0;
         if(!isHoliday)
         {
            mc["bgMC"].gotoAndStop(2);
         }
         else if(total - leftTime < 2 * 60 * 60)
         {
            mc["bgMC"].gotoAndStop(1);
         }
         else
         {
            mc["bgMC"].gotoAndStop(2);
         }
      }
      
      private static function timerHandler45(param1:TimerEvent) : void
      {
      }
   }
}

import com.robot.core.manager.*;
import flash.display.MovieClip;
import flash.events.*;
import flash.utils.*;
import org.taomee.utils.*;

class MaskScreen
{
   
   private static var mc:MovieClip;
   
   private static var timer:Timer;
   
   public function MaskScreen()
   {
      super();
   }
   
   public static function show() : void
   {
      if(!mc)
      {
         mc = AssetsManager.getMovieClip("lib_fullScreen_mc");
         timer = new Timer(1000,60);
         timer.addEventListener(TimerEvent.TIMER,onTimer);
         timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComp);
      }
      mc["txt"].text = "60";
      LevelManager.topLevel.addChild(mc);
      timer.reset();
      timer.start();
   }
   
   private static function onTimer(param1:TimerEvent) : void
   {
      mc["txt"].text = (60 - timer.currentCount).toString();
   }
   
   private static function onTimerComp(param1:TimerEvent) : void
   {
      DisplayUtil.removeForParent(mc);
   }
}
