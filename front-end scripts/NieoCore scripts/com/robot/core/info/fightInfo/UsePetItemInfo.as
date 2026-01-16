package com.robot.core.info.fightInfo
{
   import flash.utils.IDataInput;
   
   public class UsePetItemInfo
   {
      
      private var _userID:uint;
      
      private var _itemID:uint;
      
      private var _uesrHP:uint;
      
      public var changeHp:int;
      
      public function UsePetItemInfo(param1:IDataInput)
      {
         super();
         this._userID = param1.readUnsignedInt();
         this._itemID = param1.readUnsignedInt();
         this._uesrHP = param1.readUnsignedInt();
         this.changeHp = param1.readInt();
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get itemID() : uint
      {
         return this._itemID;
      }
      
      public function get userHP() : uint
      {
         return this._uesrHP;
      }
   }
}

