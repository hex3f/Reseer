package org.taomee.component.event
{
   import flash.events.Event;
   
   public class MComponentEvent extends Event
   {
      
      public static const UPDATE:String = "onUpdate";
      
      public function MComponentEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

