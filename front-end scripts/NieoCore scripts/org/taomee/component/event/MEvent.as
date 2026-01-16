package org.taomee.component.event
{
   import flash.events.Event;
   
   public class MEvent extends Event
   {
      
      public static const PANEL_CLOSED:String = "panelClosed";
      
      public function MEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

