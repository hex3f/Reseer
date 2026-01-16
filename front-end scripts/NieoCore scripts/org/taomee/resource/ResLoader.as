package org.taomee.resource
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   
   public class ResLoader extends EventDispatcher
   {
      
      public var resInfo:ResInfo;
      
      private var _loader:Loader;
      
      private var _isLoading:Boolean;
      
      public var level:int;
      
      public function ResLoader()
      {
         super();
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.OPEN,this.onOpen);
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onError);
      }
      
      public function get loaderInfo() : LoaderInfo
      {
         return this._loader.contentLoaderInfo;
      }
      
      public function set isLoading(param1:Boolean) : void
      {
         this._isLoading = param1;
      }
      
      private function onComplete(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function destroy() : void
      {
         this.close();
         this.unload();
         this.resInfo = null;
         this._loader.contentLoaderInfo.removeEventListener(Event.OPEN,this.onOpen);
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onComplete);
         this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onError);
         this._loader = null;
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
      
      public function load(param1:ResInfo) : void
      {
         this.resInfo = param1;
         this.level = this.resInfo.level;
         this.resInfo.isLoading = true;
         this._isLoading = true;
         this._loader.load(new URLRequest(this.resInfo.url));
      }
      
      private function onOpen(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         this.resInfo.isLoading = false;
         dispatchEvent(param1);
         this._isLoading = false;
      }
      
      public function close() : void
      {
         if(!this._isLoading)
         {
            return;
         }
         this._isLoading = false;
         this.resInfo.isLoading = false;
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      public function get isLoading() : Boolean
      {
         return this._isLoading;
      }
      
      public function unload() : void
      {
         this._loader.unload();
      }
   }
}

