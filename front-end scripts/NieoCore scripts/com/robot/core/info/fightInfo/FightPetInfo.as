package com.robot.core.info.fightInfo
{
   import flash.utils.IDataInput;
   
   public class FightPetInfo
   {
      
      private var _userID:uint;
      
      private var _petID:uint;
      
      private var _petName:String;
      
      private var _catchTime:uint;
      
      private var _hp:uint;
      
      private var _maxHP:uint;
      
      private var _lv:uint;
      
      private var _catchable:Boolean;
      
      private var _battleLv:Array = [];
      
      public function FightPetInfo(param1:IDataInput)
      {
         super();
         this._userID = param1.readUnsignedInt();
         this._petID = param1.readUnsignedInt();
         this._petName = param1.readUTFBytes(16);
         this._catchTime = param1.readUnsignedInt();
         this._hp = param1.readUnsignedInt();
         this._maxHP = param1.readUnsignedInt();
         this._lv = param1.readUnsignedInt();
         this._catchable = param1.readUnsignedInt() == 1;
         if(this._hp > this._maxHP)
         {
            this._maxHP = this._hp;
         }
         var _loc2_:int = 0;
         while(_loc2_ < 6)
         {
            this._battleLv.push(param1.readByte());
            _loc2_++;
         }
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get petID() : uint
      {
         return this._petID;
      }
      
      public function get petName() : String
      {
         return this._petName;
      }
      
      public function get catchTime() : uint
      {
         return this._catchTime;
      }
      
      public function get hp() : uint
      {
         return this._hp;
      }
      
      public function get maxHP() : uint
      {
         return this._maxHP;
      }
      
      public function get level() : uint
      {
         return this._lv;
      }
      
      public function get catchable() : Boolean
      {
         return this._catchable;
      }
   }
}

