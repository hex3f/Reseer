package com.robot.core.info
{
   import com.robot.core.info.pet.PetSkillInfo;
   import flash.utils.IDataInput;
   
   public class UsePetItemOutOfFightInfo
   {
      
      private var _hp:uint;
      
      private var _maxHp:uint;
      
      private var _a:uint;
      
      private var _sa:uint;
      
      private var _d:uint;
      
      private var _sd:uint;
      
      private var _sp:uint;
      
      public var catchTime:uint;
      
      public var id:uint;
      
      public var exp:uint;
      
      public var nick:String;
      
      public var nature:uint;
      
      public var dv:uint;
      
      public var lv:uint;
      
      public var ev_hp:uint;
      
      public var ev_attack:uint;
      
      public var ev_defence:uint;
      
      public var ev_sa:uint;
      
      public var ev_sd:uint;
      
      public var ev_sp:uint;
      
      private var _skillArray:Array = [];
      
      public function UsePetItemOutOfFightInfo(param1:IDataInput)
      {
         super();
         this.catchTime = param1.readUnsignedInt();
         this.id = param1.readUnsignedInt();
         this.nick = param1.readUTFBytes(16);
         this.nature = param1.readUnsignedInt();
         this.dv = param1.readUnsignedInt();
         this.lv = param1.readUnsignedInt();
         this._hp = param1.readUnsignedInt();
         this._maxHp = param1.readUnsignedInt();
         this.exp = param1.readUnsignedInt();
         this.ev_hp = param1.readUnsignedInt();
         this.ev_attack = param1.readUnsignedInt();
         this.ev_defence = param1.readUnsignedInt();
         this.ev_sa = param1.readUnsignedInt();
         this.ev_sd = param1.readUnsignedInt();
         this.ev_sp = param1.readUnsignedInt();
         this._a = param1.readUnsignedInt();
         this._sa = param1.readUnsignedInt();
         this._d = param1.readUnsignedInt();
         this._sd = param1.readUnsignedInt();
         this._sp = param1.readUnsignedInt();
         var _loc2_:uint = uint(param1.readUnsignedInt());
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            this._skillArray.push(new PetSkillInfo(param1));
            _loc3_++;
         }
      }
      
      public function get hp() : uint
      {
         return this._hp;
      }
      
      public function get maxHp() : uint
      {
         return this._maxHp;
      }
      
      public function get a() : uint
      {
         return this._a;
      }
      
      public function get sa() : uint
      {
         return this._sa;
      }
      
      public function get d() : uint
      {
         return this._d;
      }
      
      public function get sd() : uint
      {
         return this._sd;
      }
      
      public function get sp() : uint
      {
         return this._sp;
      }
      
      public function get skillArray() : Array
      {
         return this._skillArray;
      }
   }
}

