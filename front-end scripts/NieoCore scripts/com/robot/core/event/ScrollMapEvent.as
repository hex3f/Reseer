package com.robot.core.event
{
   import flash.events.Event;
   
   public class ScrollMapEvent extends Event
   {
      
      public static const SCROLL_COMPLETE:String = "scrollComplete";
      
      public function ScrollMapEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

