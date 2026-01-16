package com.common.util
{
   import com.common.byteLoader.ByteLoaderEvent;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class LoaderUtil
   {
      
      public function LoaderUtil()
      {
         super();
      }
      
      public static function pushInTXT(bytes:ByteArray) : String
      {
         return bytes.readUTFBytes(bytes.bytesAvailable);
      }
      
      public static function pushInLoader(bytes:ByteArray, context:LoaderContext, completeFun:Function = null, ioErrorFun:Function = null) : Loader
      {
         var loader:Loader = null;
         var c:Function = null;
         var f:Function = null;
         loader = new Loader();
         c = function(E:Event):*
         {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,c);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,f);
            completeFun(E);
         };
         f = function(E:IOErrorEvent):*
         {
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,c);
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,f);
            ioErrorFun(E);
         };
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,c);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,f);
         loader.loadBytes(bytes,context);
         return loader;
      }
      
      public static function addByteLoaderEvents(a:*, d:IEventDispatcher, timeoutFun:Function = null, getDataBginFun:Function = null, getByteDataFun:Function = null) : void
      {
         if(!a || !d)
         {
            throw "监听者和通知者不能为空";
         }
         try
         {
            a.BC_List;
         }
         catch(E:ReferenceError)
         {
            throw "监听者必须申明BC_List对象";
         }
         if(Boolean(timeoutFun))
         {
            BC.addEvent(a,d,ByteLoaderEvent.ON_TIME_OUT,timeoutFun);
         }
         if(Boolean(getDataBginFun))
         {
            BC.addEvent(a,d,ByteLoaderEvent.GET_DATA_BEGIN,getDataBginFun);
         }
         if(Boolean(getByteDataFun))
         {
            BC.addEvent(a,d,ByteLoaderEvent.GET_BYTE_DATA,getByteDataFun);
         }
      }
      
      public static function pushInXML(bytes:ByteArray) : XML
      {
         return XML(bytes.readUTFBytes(bytes.bytesAvailable));
      }
      
      public static function joinMainApplicatrionDomain() : LoaderContext
      {
         return new LoaderContext(false,ApplicationDomain.currentDomain);
      }
      
      public static function addLoaderEvents(a:*, d:IEventDispatcher, completeFun:Function = null, ioErrorFun:Function = null, openFun:Function = null, progressFun:Function = null, securityErrorFun:Function = null, httpStatusFun:Function = null) : void
      {
         var isLoader:Loader;
         if(!a || !d)
         {
            throw "监听者和通知者不能为空";
         }
         try
         {
            a.BC_List;
         }
         catch(E:ReferenceError)
         {
            throw "监听者必须申明BC_List对象";
         }
         isLoader = d as Loader;
         if(Boolean(isLoader))
         {
            d = isLoader.contentLoaderInfo as IEventDispatcher;
         }
         if(Boolean(completeFun))
         {
            BC.addEvent(a,d,Event.COMPLETE,completeFun);
         }
         if(Boolean(ioErrorFun))
         {
            BC.addEvent(a,d,IOErrorEvent.IO_ERROR,ioErrorFun);
         }
         if(Boolean(openFun))
         {
            BC.addEvent(a,d,Event.OPEN,openFun);
         }
         if(Boolean(progressFun))
         {
            BC.addEvent(a,d,ProgressEvent.PROGRESS,progressFun);
         }
         if(Boolean(securityErrorFun))
         {
            BC.addEvent(a,d,SecurityErrorEvent.SECURITY_ERROR,securityErrorFun);
         }
         if(Boolean(httpStatusFun))
         {
            BC.addEvent(a,d,HTTPStatusEvent.HTTP_STATUS,httpStatusFun);
         }
      }
   }
}

