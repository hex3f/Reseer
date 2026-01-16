package com.robot.app.info.item
{
   import flash.utils.IDataInput;
   
   public class BuyMultiItemInfo
   {
      
      private var _cash:uint;
      
      public function BuyMultiItemInfo(param1:IDataInput)
      {
         super();
         this._cash = param1.readUnsignedInt();
      }
      
      public function get cash() : uint
      {
         return this._cash;
      }
   }
}

