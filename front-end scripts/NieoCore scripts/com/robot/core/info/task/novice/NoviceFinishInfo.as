package com.robot.core.info.task.novice
{
   import flash.utils.IDataInput;
   
   public class NoviceFinishInfo
   {
      
      private var _taskID:uint;
      
      private var _petID:uint;
      
      private var _captureTm:uint;
      
      private var _itemID:uint;
      
      private var _itemCnt:uint;
      
      private var _monBallList:Array;
      
      public function NoviceFinishInfo(param1:IDataInput)
      {
         super();
         this._monBallList = new Array();
         this._taskID = param1.readUnsignedInt();
         this._petID = param1.readUnsignedInt();
         this._captureTm = param1.readUnsignedInt();
         var _loc2_:uint = param1.readUnsignedInt();
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
      
      public function get taskID() : uint
      {
         return this._taskID;
      }
      
      public function get captureTm() : uint
      {
         return this._captureTm;
      }
   }
}

