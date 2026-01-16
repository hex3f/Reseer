package org.taomee.events
{
   import flash.events.Event;
   import org.taomee.tmf.HeadInfo;
   
   public class SocketErrorEvent extends Event
   {
      
      public static const ERROR:String = "error";
      
      private var _headInfo:HeadInfo;
      
      public function SocketErrorEvent(param1:String, param2:HeadInfo, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._headInfo = param2;
      }
      
      public function get headInfo() : HeadInfo
      {
         return this._headInfo;
      }
   }
}

