package com.robot.core.event
{
   import com.robot.core.info.UserInfo;
   import flash.events.Event;
   
   public class UserEvent extends Event
   {
      
      public static const CLICK:String = "userClick";
      
      public static const INFO_CHANGE:String = "infoChange";
      
      public static const REMOVED_FROM_MAP:String = "removedFromMap";
      
      private var _userInfo:UserInfo;
      
      public function UserEvent(param1:String, param2:UserInfo = null, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._userInfo = param2;
      }
      
      public function get userInfo() : UserInfo
      {
         return this._userInfo;
      }
   }
}

