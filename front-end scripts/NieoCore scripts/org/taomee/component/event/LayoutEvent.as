package org.taomee.component.event
{
   import flash.events.Event;
   
   public class LayoutEvent extends Event
   {
      
      public static const LAYOUT_SET_CHANGED:String = "layoutSetChanged";
      
      public function LayoutEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

