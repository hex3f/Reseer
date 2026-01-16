package com.common.byteLoader
{
   import com.common.util.LoaderUtil;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.Timer;
   
   [Event(name="getByteData",type="ByteLoaderEvent")]
   [Event(name="getDataBegin",type="ByteLoaderEvent")]
   [Event(name="onTimeout",type="ByteLoaderEvent")]
   public class ByteLoader extends URLStream implements IDataInput, IByteLoader
   {
      
      private var _timeoutDelay:uint;
      
      private var _timeoutCount:uint = 0;
      
      private var _bytesLoaded:uint = 0;
      
      private var _reLoadCount:uint = 0;
      
      private var _checkTimeout:Boolean;
      
      protected var overtime:Timer;
      
      private var _bytesTotal:uint = 0;
      
      private var c_Available:uint = 0;
      
      private var _request:URLRequest;
      
      protected var cba:ByteArray;
      
      public var BC_List:Object;
      
      public function ByteLoader(checkTimeout:Boolean = false, timeoutDelay:uint = 15000)
      {
         _checkTimeout = checkTimeout;
         _timeoutDelay = timeoutDelay;
         super();
      }
      
      public function get delay() : uint
      {
         return _timeoutDelay;
      }
      
      override public function readShort() : int
      {
         return cba.readShort();
      }
      
      public function reTry() : void
      {
         if(connected)
         {
            close();
         }
         ++_reLoadCount;
         beginLoading();
      }
      
      public function addCheckTimeout(timeoutDelay:uint = 15000) : void
      {
         _checkTimeout = true;
         _timeoutDelay = timeoutDelay;
      }
      
      override public function readDouble() : Number
      {
         return cba.readDouble();
      }
      
      public function getByteArray() : ByteArray
      {
         var tb:ByteArray = new ByteArray();
         tb.writeBytes(cba);
         tb.position = 0;
         return tb;
      }
      
      public function getURLRequest() : URLRequest
      {
         return _request;
      }
      
      public function get bytesTotal() : uint
      {
         return _bytesTotal;
      }
      
      private function onIoError(E:IOErrorEvent) : void
      {
         BC.removeEvent(this);
         if(Boolean(overtime))
         {
            overtime.stop();
         }
         overtime = null;
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_TIME_OUT));
         trace("\n\n",E);
      }
      
      private function addTimer() : void
      {
         if(_checkTimeout)
         {
            if(!overtime || overtime && overtime.running)
            {
               overtime = new Timer(_timeoutDelay,0);
               BC.addEvent(this,overtime,TimerEvent.TIMER,checkIsTimeout);
               LoaderUtil.addLoaderEvents(this,this,onComplete,onIoError);
            }
         }
      }
      
      override public function get bytesAvailable() : uint
      {
         return cba.bytesAvailable;
      }
      
      private function getFileBytesTotal(E:ProgressEvent) : void
      {
         BC.removeEvent(this,this,ProgressEvent.PROGRESS,getFileBytesTotal);
         _bytesLoaded = E.bytesLoaded;
         _bytesTotal = E.bytesTotal;
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.GET_DATA_BEGIN));
      }
      
      private function checkIsTimeout(E:TimerEvent) : void
      {
         if(c_Available != _bytesLoaded)
         {
            c_Available = _bytesLoaded;
         }
         else
         {
            ++_timeoutCount;
            dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_TIME_OUT));
         }
      }
      
      override public function readBoolean() : Boolean
      {
         return cba.readBoolean();
      }
      
      public function get timeoutCount() : uint
      {
         return _timeoutCount;
      }
      
      override public function readUTFBytes(lenght:uint) : String
      {
         return cba.readUTFBytes(lenght);
      }
      
      override public function readObject() : *
      {
         return cba.readObject();
      }
      
      override public function readByte() : int
      {
         return cba.readByte();
      }
      
      private function onComplete(E:Event) : void
      {
         BC.removeEvent(this);
         if(Boolean(overtime))
         {
            overtime.stop();
         }
         overtime = null;
      }
      
      override public function readUTF() : String
      {
         return cba.readUTF();
      }
      
      override public function readUnsignedShort() : uint
      {
         return cba.readUnsignedShort();
      }
      
      override public function readUnsignedInt() : uint
      {
         return cba.readUnsignedInt();
      }
      
      protected function beginLoading() : void
      {
         cba = new ByteArray();
         c_Available = 0;
         addTimer();
         if(_checkTimeout && Boolean(overtime))
         {
            overtime.start();
         }
         BC.addEvent(this,this,ProgressEvent.PROGRESS,getFileBytesTotal);
         BC.addEvent(this,this,ProgressEvent.PROGRESS,pushDataToByteArray);
         super.load(_request);
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.ON_START_LOAD));
      }
      
      public function get bytesLoaded() : uint
      {
         return _bytesLoaded;
      }
      
      override public function readUnsignedByte() : uint
      {
         return cba.readUnsignedByte();
      }
      
      public function get reTryCount() : uint
      {
         return _reLoadCount;
      }
      
      override public function readMultiByte(length:uint, charSet:String) : String
      {
         return cba.readMultiByte(length,charSet);
      }
      
      override public function load(request:URLRequest) : void
      {
         if(!(Boolean(_request) && Boolean(request) && _request === request))
         {
            _reLoadCount = 0;
         }
         _request = request;
         _timeoutCount = 0;
         beginLoading();
      }
      
      private function pushDataToByteArray(E:ProgressEvent) : void
      {
         _bytesLoaded = E.bytesLoaded;
         _bytesTotal = E.bytesTotal;
         super.readBytes(cba,cba.length);
         dispatchEvent(new ByteLoaderEvent(ByteLoaderEvent.GET_BYTE_DATA));
      }
      
      override public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0) : void
      {
         cba.readBytes(bytes,offset,length);
      }
      
      override public function readInt() : int
      {
         return cba.readInt();
      }
      
      override public function readFloat() : Number
      {
         return cba.readFloat();
      }
      
      override public function close() : void
      {
         super.close();
         BC.removeEvent(this);
         cba = new ByteArray();
         c_Available = 0;
         if(Boolean(overtime))
         {
            overtime.stop();
         }
         overtime = null;
      }
   }
}

