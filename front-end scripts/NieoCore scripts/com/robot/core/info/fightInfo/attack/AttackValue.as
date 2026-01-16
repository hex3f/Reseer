package com.robot.core.info.fightInfo.attack
{
   import com.robot.core.info.pet.PetSkillInfo;
   import flash.utils.IDataInput;
   
   public class AttackValue
   {
      
      private var _userID:uint;
      
      private var _skillID:uint;
      
      private var _atkTimes:uint;
      
      private var _lostHP:uint;
      
      private var _gainHP:int;
      
      private var _remainHp:int;
      
      private var _maxHp:uint;
      
      private var _isCrit:uint;
      
      private var _status:Array;
      
      private var _state:uint;
      
      private var _battleLv:Array;
      
      private var _skillInfoArray:Array;
      
      private var _maxShield:uint;
      
      private var _curShield:uint;
      
      private var _petType:uint;
      
      public function AttackValue(param1:IDataInput)
      {
         var _loc2_:PetSkillInfo = null;
         this._battleLv = [];
         this._skillInfoArray = [];
         this._status = [];
         super();
         this._userID = param1.readUnsignedInt();
         this._skillID = param1.readUnsignedInt();
         this._atkTimes = param1.readUnsignedInt();
         this._lostHP = param1.readUnsignedInt();
         this._gainHP = param1.readInt();
         this._remainHp = param1.readInt();
         this._maxHp = param1.readUnsignedInt();
         this._state = param1.readUnsignedInt();
         var _loc3_:uint = uint(param1.readUnsignedInt());
         var _loc4_:Number = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = new PetSkillInfo(param1);
            this._skillInfoArray.push(_loc2_);
            _loc4_++;
         }
         this._isCrit = param1.readUnsignedInt();
         _loc4_ = 0;
         while(_loc4_ < 20)
         {
            this._status.push(param1.readByte());
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 6)
         {
            this._battleLv.push(param1.readByte());
            _loc4_++;
         }
         this._maxShield = param1.readUnsignedInt();
         this._curShield = param1.readUnsignedInt();
         this._petType = param1.readUnsignedInt();
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function get skillID() : uint
      {
         return this._skillID;
      }
      
      public function get lostHP() : uint
      {
         return this._lostHP;
      }
      
      public function get gainHP() : int
      {
         return this._gainHP;
      }
      
      public function get remainHP() : int
      {
         return this._remainHp;
      }
      
      public function get isCrit() : Boolean
      {
         return this._isCrit == 1;
      }
      
      public function get atkTimes() : uint
      {
         return this._atkTimes;
      }
      
      public function get status() : Array
      {
         return this._status;
      }
      
      public function get maxHp() : uint
      {
         return this._maxHp;
      }
      
      public function get state() : uint
      {
         return this._state;
      }
      
      public function get battleLv() : Array
      {
         return this._battleLv;
      }
      
      public function get skillInfoArray() : Array
      {
         return this._skillInfoArray;
      }
      
      public function get maxShield() : uint
      {
         return this._maxShield;
      }
      
      public function get curShield() : uint
      {
         return this._curShield;
      }
      
      public function get getPetType() : uint
      {
         return this._petType;
      }
   }
}

