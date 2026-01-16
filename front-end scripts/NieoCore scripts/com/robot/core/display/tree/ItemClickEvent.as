package com.robot.core.display.tree
{
   import flash.events.Event;
   
   public class ItemClickEvent extends Event
   {
      
      public static const ITEMCLICK:String = "itemclick";
      
      public var item:Btn;
      
      public function ItemClickEvent(param1:Btn, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         super(param2,param3,param4);
         this.item = param1;
      }
   }
}

