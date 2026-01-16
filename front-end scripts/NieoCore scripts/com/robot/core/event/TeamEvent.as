package com.robot.core.event
{
   import flash.events.Event;
   
   public class TeamEvent extends Event
   {
      
      public static const MODIFY_LOGO:String = "modifyLogo";
      
      public function TeamEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

