package com.common.byteLoader
{
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public interface IByteLoader
   {
      
      function get delay() : uint;
      
      function load(param1:URLRequest) : void;
      
      function get reTryCount() : uint;
      
      function reTry() : void;
      
      function get timeoutCount() : uint;
      
      function get bytesLoaded() : uint;
      
      function getURLRequest() : URLRequest;
      
      function close() : void;
      
      function get bytesTotal() : uint;
      
      function addCheckTimeout(param1:uint = 15000) : void;
      
      function getByteArray() : ByteArray;
      
      function get bytesAvailable() : uint;
   }
}

