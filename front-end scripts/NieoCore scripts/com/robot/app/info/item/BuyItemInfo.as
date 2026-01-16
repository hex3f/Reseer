package com.robot.app.info.item
{
   import flash.utils.IDataInput;
   
   public class BuyItemInfo
   {
      
      private var _cash:uint;
      
      private var _itemID:uint;
      
      private var _itemLevel:uint;
      
      private var _itemNum:uint;
      
      public function BuyItemInfo(param1:IDataInput)
      {
         super();
         this._cash = param1.readUnsignedInt();
         this._itemID = param1.readUnsignedInt();
         this._itemNum = param1.readUnsignedInt();
         this._itemLevel = param1.readUnsignedInt();
      }
      
      public function get cash() : uint
      {
         return this._cash;
      }
      
      public function get itemID() : uint
      {
         return this._itemID;
      }
      
      public function get itemLevel() : uint
      {
         return this._itemLevel;
      }
      
      public function get itemNum() : uint
      {
         return this._itemNum;
      }
   }
}

