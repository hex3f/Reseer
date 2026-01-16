package org.taomee.events
{
   import flash.events.Event;
   import org.taomee.tmf.HeadInfo;
   
   public class SocketEvent extends Event
   {
      
      public static const COMPLETE:String = Event.COMPLETE;
      
      private var _data:Object;
      
      private var _headInfo:HeadInfo;
      
      public function SocketEvent(param1:String, param2:HeadInfo, param3:Object)
      {
         super(param1,false,false);
         this._headInfo = param2;
         this._data = param3;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function get headInfo() : HeadInfo
      {
         return this._headInfo;
      }
   }
}

