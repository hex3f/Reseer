package com.robot.core.info.userItem
{
   import com.robot.core.utils.ItemType;
   import flash.utils.IDataInput;
   
   public class SingleItemInfo
   {
      
      private var _itemID:uint;
      
      private var _itemLevel:uint;
      
      public var itemNum:uint;
      
      public var leftTime:uint;
      
      public var type:uint;
      
      public function SingleItemInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this.itemID = param1.readUnsignedInt();
            this.itemNum = param1.readUnsignedInt();
            this.leftTime = param1.readUnsignedInt();
            this._itemLevel = param1.readUnsignedInt();
         }
      }
      
      public function set itemID(param1:uint) : void
      {
         this._itemID = param1;
         if(this._itemID > 10000 && this._itemID < 100000)
         {
            this.type = ItemType.COLLECTON;
         }
         else if(this._itemID >= 100001 && this._itemID <= 200000 || this._itemID >= 1300001 && this._itemID <= 1400000)
         {
            this.type = ItemType.CLOTH;
         }
         else if(this._itemID >= 200001 && this._itemID <= 300000)
         {
            this.type = ItemType.DOODLE;
         }
         else if(this._itemID >= 300001 && this._itemID <= 400000)
         {
            this.type = ItemType.PET_PROPERTY;
         }
         else if(this._itemID >= 400001 && this._itemID <= 500000 || this._itemID >= 1200001 && this._itemID <= 1300000)
         {
            this.type = ItemType.COLLECTON;
         }
         else if(this._itemID >= 500001 && this._itemID <= 600000)
         {
            this.type = ItemType.FITMENT;
         }
         else if(this._itemID >= 1000001 && this._itemID <= 1100000)
         {
            this.type = ItemType.SOULBEAD;
         }
         else if(this._itemID > 1500000 && this._itemID < 1600000)
         {
            this.type = ItemType.COLLECTON;
         }
         else
         {
            this.type = ItemType.SUIT;
         }
      }
      
      public function get itemID() : uint
      {
         return this._itemID;
      }
      
      public function get itemLevel() : uint
      {
         return this._itemLevel;
      }
   }
}

