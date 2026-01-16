package com.robot.core.event
{
   import com.robot.core.info.NonoInfo;
   import flash.events.Event;
   
   public class NonoEvent extends Event
   {
      
      public static const INFO_CHANGE:String = "infoChange";
      
      public static const GET_INFO:String = "getInfo";
      
      public static const FOLLOW:String = "follw";
      
      public static const HOOM:String = "hoom";
      
      public static const PLAY_COMPLETE:String = "playComplete";
      
      private var _info:NonoInfo;
      
      public function NonoEvent(param1:String, param2:NonoInfo)
      {
         super(param1,false,false);
         this._info = param2;
      }
      
      public function get info() : NonoInfo
      {
         return this._info;
      }
   }
}

