package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class AlertInfo
   {
      
      private var _msg:String = "";
      
      private var _msgLength:int = 0;
      
      public function AlertInfo(param1:IDataInput)
      {
         super();
         this._msgLength = param1.readUnsignedInt();
         this._msg = param1.readUTFBytes(this._msgLength);
      }
      
      public function get msg() : String
      {
         return this._msg;
      }
   }
}

