package com.robot.core.info.HatchTask
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class HatchTaskBufInfo
   {
      
      private var _ObtainTm:uint;
      
      private var _buf:ByteArray = new ByteArray();
      
      public function HatchTaskBufInfo(param1:IDataInput)
      {
         super();
         this._ObtainTm = param1.readUnsignedInt();
         param1.readBytes(this._buf);
      }
      
      public function get obtainTm() : uint
      {
         return this._ObtainTm;
      }
      
      public function get buf() : ByteArray
      {
         return this._buf;
      }
   }
}

