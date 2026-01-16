package org.taomee.component.event
{
   import flash.events.Event;
   import org.taomee.component.UIComponent;
   
   public class ContainerEvent extends Event
   {
      
      public static const COMP_ADDED:String = "compAdded";
      
      public static const COMP_REMOVED:String = "compRemoved";
      
      private var comp:UIComponent;
      
      public function ContainerEvent(param1:String, param2:UIComponent, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.comp = param2;
      }
      
      public function get component() : UIComponent
      {
         return this.comp;
      }
   }
}

