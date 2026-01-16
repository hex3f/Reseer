package com.robot.core.manager
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class SystemTimerManager
   {
      
      private static var _timer:Timer;
      
      private static var _sysTime:uint;
      
      private static var _tickFun:Array = [];
      
      public function SystemTimerManager()
      {
         super();
      }
      
      public static function setTime(param1:uint) : void
      {
         _sysTime = param1;
         if(_timer == null)
         {
            _timer = new Timer(1000);
            _timer.addEventListener(TimerEvent.TIMER,onTimer);
         }
         _timer.reset();
         _timer.start();
      }
      
      private static function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Function = null;
         _sysTime += 1;
         for each(_loc2_ in _tickFun)
         {
            _loc2_();
         }
      }
      
      public static function get time() : uint
      {
         return _sysTime;
      }
      
      public static function get sysDate() : Date
      {
         return new Date(_sysTime * 1000);
      }
      
      public static function getSysTime(param1:Function = null) : void
      {
         param1(_sysTime);
      }
      
      public static function getTimeByDate(param1:uint, param2:uint, param3:uint, param4:uint, param5:uint = 0, param6:uint = 0) : uint
      {
         var _loc7_:Date = new Date(param1,param2 - 1,param3,param4,param5,param6);
         return uint(_loc7_.time / 1000 - (28800 + _loc7_.getTimezoneOffset() * 60));
      }
      
      public static function getTimeClockString(param1:int) : String
      {
         if(param1 < 0)
         {
            return "00:00:00";
         }
         var _loc2_:int = param1 / 3600;
         var _loc3_:int = (param1 - _loc2_ * 3600) / 60;
         var _loc4_:int = param1 - _loc2_ * 3600 - _loc3_ * 60;
         return (_loc2_ > 9 ? _loc2_ : "0" + _loc2_) + ":" + (_loc3_ > 9 ? _loc3_ : "0" + _loc3_) + ":" + (_loc4_ > 9 ? _loc4_ : "0" + _loc4_);
      }
      
      public static function addTickFun(param1:Function) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(_tickFun.indexOf(param1) == -1)
         {
            _tickFun.push(param1);
         }
      }
      
      public static function removeTickFun(param1:Function) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(_tickFun.indexOf(param1) != -1)
         {
            _tickFun.splice(_tickFun.indexOf(param1),1);
         }
      }
      
      public static function get timezone() : int
      {
         return sysDate.timezoneOffset / -60;
      }
   }
}

