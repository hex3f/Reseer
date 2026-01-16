package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class ExchangeInfo
   {
      
      public var _exchangeID:uint;
      
      public var _exchangeNum:uint;
      
      public function ExchangeInfo(param1:IDataInput = null)
      {
         super();
         if(param1 != null)
         {
            this._exchangeID = param1.readUnsignedInt();
            this._exchangeNum = param1.readUnsignedInt();
         }
      }
      
      public function set exchangeID(param1:uint) : void
      {
         this._exchangeID = param1;
      }
      
      public function get exchangeID() : uint
      {
         return this._exchangeID;
      }
      
      public function set exchangeNum(param1:uint) : void
      {
         this._exchangeNum = param1;
      }
      
      public function get exchangeNum() : uint
      {
         return this._exchangeNum;
      }
   }
}

