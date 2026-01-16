package org.taomee.component.event
{
   import flash.events.Event;
   
   public class ButtonEvent extends Event
   {
      
      public static const ON_ROLL_OVER:String = "onRollOver";
      
      public static const ON_ROLL_OUT:String = "onRollOut";
      
      public static const PRESS:String = "press";
      
      public static const RELEASE:String = "release";
      
      public static const RELEASE_OUTSIDE:String = "releaseOutside";
      
      public function ButtonEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

