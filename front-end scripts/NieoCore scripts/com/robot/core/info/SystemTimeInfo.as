package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class SystemTimeInfo
   {
      
      private var _date:Date;
      
      private var _time:uint;
      
      public function SystemTimeInfo(param1:IDataInput)
      {
         super();
         this._time = uint(param1.readUnsignedInt());
         this._date = new Date(this._time * 1000);
      }
      
      public function get date() : Date
      {
         return this._date;
      }
      
      public function get time() : int
      {
         return this._time;
      }
   }
}

