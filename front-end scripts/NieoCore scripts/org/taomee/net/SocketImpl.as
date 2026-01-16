package org.taomee.net
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketErrorEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.tmf.HeadInfo;
   import org.taomee.tmf.TMF;
   
   public class SocketImpl extends Socket
   {
      
      public static const PACKAGE_MAX:uint = 8388608;
      
      public var port:int;
      
      private var _headLength:uint = 17;
      
      private var _headInfo:HeadInfo;
      
      private var _dataLen:uint;
      
      private var _isGetHead:Boolean = true;
      
      private var _packageLen:uint;
      
      public var session:ByteArray;
      
      private var _version:String = "1";
      
      public var userID:uint = 0;
      
      public var ip:String;
      
      private var outTime:int = 0;
      
      private var _result:uint = 0;
      
      public function SocketImpl(param1:String = "1")
      {
         super();
         this._version = param1;
         this._headLength = SocketVersion.getHeadLength(param1);
      }
      
      public function send(param1:uint, param2:Array) : uint
      {
         var _loc3_:* = undefined;
         var _loc4_:ByteArray = new ByteArray();
         for each(_loc3_ in param2)
         {
            if(_loc3_ is String)
            {
               _loc4_.writeUTFBytes(_loc3_);
            }
            else if(_loc3_ is ByteArray)
            {
               _loc4_.writeBytes(_loc3_);
            }
            else
            {
               _loc4_.writeUnsignedInt(_loc3_);
            }
         }
         if(param1 > 1000)
         {
            ++this._result;
         }
         var _loc5_:uint = _loc4_.length + this._headLength;
         writeUnsignedInt(_loc5_);
         writeUTFBytes(this._version);
         writeUnsignedInt(param1);
         writeUnsignedInt(this.userID);
         writeInt(this._result);
         if(this._version == SocketVersion.SV_2)
         {
            writeInt(0);
         }
         writeBytes(_loc4_);
         flush();
         return this._result;
      }
      
      public function get version() : String
      {
         return this._version;
      }
      
      private function onData(param1:Event) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Class = null;
         this.outTime = 0;
         while(bytesAvailable > 0)
         {
            if(this._isGetHead)
            {
               if(bytesAvailable >= this._headLength)
               {
                  this._packageLen = readUnsignedInt();
                  if(this._packageLen < this._headLength || this._packageLen > PACKAGE_MAX)
                  {
                     SocketDispatcher.getInstance().dispatchEvent(new SocketErrorEvent(SocketErrorEvent.ERROR,null));
                     readBytes(new ByteArray());
                     return;
                  }
                  this._headInfo = new HeadInfo(this,this._version);
                  if(this._version == SocketVersion.SV_1)
                  {
                     if(this._headInfo.result != 0)
                     {
                        SocketDispatcher.getInstance().dispatchEvent(new SocketErrorEvent(SocketErrorEvent.ERROR,this._headInfo));
                        continue;
                     }
                  }
                  else if(this._version == SocketVersion.SV_2)
                  {
                     if(this._headInfo.error != 0)
                     {
                        SocketDispatcher.getInstance().dispatchEvent(new SocketErrorEvent(SocketErrorEvent.ERROR,this._headInfo));
                        continue;
                     }
                  }
                  this._dataLen = this._packageLen - this._headLength;
                  if(this._dataLen == 0)
                  {
                     SocketDispatcher.getInstance().dispatchEvent(new SocketEvent(this._headInfo.cmdID.toString(),this._headInfo,null));
                     continue;
                  }
                  this._isGetHead = false;
               }
            }
            else if(bytesAvailable >= this._dataLen)
            {
               _loc2_ = new ByteArray();
               readBytes(_loc2_,0,this._dataLen);
               _loc3_ = TMF.getClass(this._headInfo.cmdID);
               SocketDispatcher.getInstance().dispatchEvent(new SocketEvent(this._headInfo.cmdID.toString(),this._headInfo,new _loc3_(_loc2_)));
               this._isGetHead = true;
            }
            if(this.outTime > 200 || !connected)
            {
               break;
            }
            ++this.outTime;
         }
      }
      
      override public function connect(param1:String, param2:int) : void
      {
         super.connect(param1,param2);
         this._result = 0;
         this.addEvent();
      }
      
      private function removeEvent() : void
      {
         removeEventListener(ProgressEvent.SOCKET_DATA,this.onData);
      }
      
      private function addEvent() : void
      {
         addEventListener(ProgressEvent.SOCKET_DATA,this.onData);
      }
      
      override public function close() : void
      {
         this.removeEvent();
         if(connected)
         {
            super.close();
         }
         this.ip = "";
         this.port = -1;
         this._result = 0;
      }
   }
}

