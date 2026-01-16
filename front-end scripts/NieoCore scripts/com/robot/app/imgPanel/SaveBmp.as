package com.robot.app.imgPanel
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLRequest;
   
   public class SaveBmp
   {
      
      private static var file:FileReference;
      
      public function SaveBmp()
      {
         super();
      }
      
      public static function download(param1:String) : void
      {
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.url = param1;
         file = new FileReference();
         var _loc3_:String = "赛尔截图_" + new Date().valueOf() + ".jpg";
         configureListeners();
         file.download(_loc2_,_loc3_);
      }
      
      private static function configureListeners() : void
      {
         file.addEventListener(Event.CANCEL,cancelHandler);
         file.addEventListener(Event.COMPLETE,completeHandler);
         file.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         file.addEventListener(ProgressEvent.PROGRESS,progressHandler);
         file.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
      }
      
      private static function removeConfigureListeners() : void
      {
         file.removeEventListener(Event.CANCEL,cancelHandler);
         file.removeEventListener(Event.COMPLETE,completeHandler);
         file.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         file.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
         file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
      }
      
      private static function cancelHandler(param1:Event) : void
      {
         removeConfigureListeners();
      }
      
      private static function completeHandler(param1:Event) : void
      {
         removeConfigureListeners();
      }
      
      private static function ioErrorHandler(param1:IOErrorEvent) : void
      {
         removeConfigureListeners();
      }
      
      private static function progressHandler(param1:ProgressEvent) : void
      {
         var _loc2_:FileReference = FileReference(param1.target);
      }
      
      private static function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         removeConfigureListeners();
      }
   }
}

