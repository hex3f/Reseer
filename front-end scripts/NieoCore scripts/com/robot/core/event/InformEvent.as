package com.robot.core.event
{
   import com.robot.core.info.InformInfo;
   import flash.events.Event;
   
   public class InformEvent extends Event
   {
      
      public static const INFORM:String = "inform";
      
      private var _info:InformInfo;
      
      public function InformEvent(param1:String, param2:InformInfo)
      {
         super(param1,false,false);
         this._info = param2;
      }
      
      public function get info() : InformInfo
      {
         return this._info;
      }
   }
}

