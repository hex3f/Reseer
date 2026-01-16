package com.robot.core.temp
{
   import flash.utils.IDataInput;
   
   public class AresiaSpacePrize
   {
      
      private var _bonusID:uint;
      
      private var _petID:uint;
      
      private var _captureTm:uint;
      
      private var _itemID:uint;
      
      private var _itemCnt:uint;
      
      private var _monBallList:Array;
      
      public function AresiaSpacePrize(param1:IDataInput)
      {
         super();
         this._bonusID = param1.readUnsignedInt();
         this._petID = param1.readUnsignedInt();
         this._captureTm = param1.readUnsignedInt();
         this._monBallList = new Array();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._itemID = param1.readUnsignedInt();
            this._itemCnt = param1.readUnsignedInt();
            this._monBallList.push({
               "itemID":this._itemID,
               "itemCnt":this._itemCnt
            });
            _loc3_++;
         }
      }
      
      public function get monBallList() : Array
      {
         return this._monBallList;
      }
      
      public function get petID() : uint
      {
         return this._petID;
      }
      
      public function get captureTm() : uint
      {
         return this._captureTm;
      }
   }
}

