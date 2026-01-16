package org.taomee.component.event
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LoadPaneEvent extends Event
   {
      
      public static const ON_LOAD_CONTENT:String = "onLoadContent";
      
      private var content:DisplayObject;
      
      public function LoadPaneEvent(param1:String, param2:DisplayObject, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.content = param2;
      }
      
      public function getContent() : DisplayObject
      {
         return this.content;
      }
   }
}

