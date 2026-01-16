package org.taomee.utils
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.clearInterval;
   import flash.utils.clearTimeout;
   import flash.utils.setInterval;
   import flash.utils.setTimeout;
   
   public class TimerUtil
   {
      
      public function TimerUtil()
      {
         super();
      }
      
      public static function clearAllTimer() : void
      {
         clearAllTimeout();
         clearAllInterval();
      }
      
      private static function getTimerInstance(param1:Function, param2:Number, param3:uint, param4:*) : Timer
      {
         var tempTimer:Timer = null;
         var closure:Function = param1;
         var delay:Number = param2;
         var num:uint = param3;
         var vars:* = param4;
         tempTimer = null;
         tempTimer = new Timer(delay,num);
         tempTimer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
         {
            if(param1.currentTarget.currentCount == param1.currentTarget.repeatCount)
            {
               tempTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,arguments.callee);
               clearGTimeout(tempTimer);
            }
            if(vars.length > 0)
            {
               closure.apply(this,vars);
            }
            else
            {
               closure();
            }
         });
         tempTimer.start();
         return tempTimer;
      }
      
      public static function clearGTimeout(param1:Timer) : void
      {
         if(Boolean(param1))
         {
            param1.stop();
            param1 = null;
         }
      }
      
      public static function clearAllInterval() : void
      {
         var timeoutNum:uint = 0;
         timeoutNum = 0;
         timeoutNum = setInterval(function():void
         {
            var i:* = undefined;
            timeoutNum = setInterval(function():void
            {
            },0);
            i = 1;
            while(i <= timeoutNum)
            {
               clearInterval(i);
               i++;
            }
         },0);
      }
      
      public static function setGInterval(param1:Function, param2:*, ... rest) : Timer
      {
         var _loc4_:* = 0;
         var _loc5_:Array = null;
         if(Boolean(param2 as String) && param2.indexOf(":") > -1)
         {
            _loc5_ = param2.split(":");
            _loc4_ = uint(int(_loc5_[1]));
            param2 = int(_loc5_[0]);
         }
         else
         {
            _loc4_ = 0;
         }
         return getTimerInstance(param1,param2,_loc4_,rest);
      }
      
      public static function setGTimeout(param1:Function, param2:Number, ... rest) : Timer
      {
         return getTimerInstance(param1,param2,1,rest);
      }
      
      public static function clearAllTimeout() : void
      {
         var timeoutNum:uint = 0;
         timeoutNum = 0;
         timeoutNum = setTimeout(function():void
         {
            var i:* = undefined;
            timeoutNum = setTimeout(function():void
            {
            },0);
            i = 1;
            while(i <= timeoutNum)
            {
               clearTimeout(i);
               i++;
            }
         },0);
      }
      
      public static function clearGInterval(param1:Timer) : void
      {
         if(Boolean(param1))
         {
            param1.stop();
            param1 = null;
         }
      }
   }
}

