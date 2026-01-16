package com.robot.core.newloader
{
   import com.robot.core.event.XMLLoadEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   [Event(name="onSuccess",type="com.event.XMLLoadEvent")]
   [Event(name="error",type="com.event.XMLLoadEvent")]
   public class XMLLoader extends URLLoader
   {
      
      private var url:String;
      
      public function XMLLoader(param1:String)
      {
         super();
         this.url = param1;
         this.addEventListener(Event.COMPLETE,this._onLoad);
         this.addEventListener(IOErrorEvent.IO_ERROR,this._error);
      }
      
      public function doLoad(param1:String = "") : void
      {
         if(param1 == "")
         {
            this.load(new URLRequest(this.url));
         }
         else
         {
            this.addEventListener(Event.COMPLETE,this._onLoad);
            this.addEventListener(IOErrorEvent.IO_ERROR,this._error);
            this.load(new URLRequest(param1));
         }
      }
      
      private function _onLoad(param1:Event) : void
      {
         this.removeEventListener(Event.COMPLETE,this._onLoad);
         this.removeEventListener(IOErrorEvent.IO_ERROR,this._error);
         dispatchEvent(new XMLLoadEvent(XMLLoadEvent.ON_SUCCESS,this));
      }
      
      private function _error(param1:IOErrorEvent) : void
      {
         this.removeEventListener(Event.COMPLETE,this._onLoad);
         this.removeEventListener(IOErrorEvent.IO_ERROR,this._error);
         dispatchEvent(new XMLLoadEvent(XMLLoadEvent.ERROR,this));
      }
   }
}

