package org.taomee.events
{
   import flash.events.Event;
   
   public class DynamicEvent extends Event
   {
      
      private var _paramObject:Object;
      
      public function DynamicEvent(param1:String, param2:Object = null)
      {
         super(param1,false,false);
         this._paramObject = param2;
      }
      
      public function get paramObject() : Object
      {
         return this._paramObject;
      }
      
      override public function clone() : Event
      {
         return new DynamicEvent(type,this._paramObject);
      }
   }
}

