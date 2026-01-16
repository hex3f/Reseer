package com.robot.core.event
{
   import com.robot.core.info.SystemTimeInfo;
   import flash.events.Event;
   
   public class SysTimeEvent extends Event
   {
      
      public static const RECEIVE_SYSTEM_TIME:String = "receive_system_time";
      
      public static const CURRENT_SYS_TIME:String = "current_system_time";
      
      private var _timeInfo:SystemTimeInfo;
      
      public function SysTimeEvent(param1:String, param2:SystemTimeInfo = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._timeInfo = param2;
      }
      
      public function get timeInfo() : SystemTimeInfo
      {
         return this._timeInfo;
      }
   }
}

