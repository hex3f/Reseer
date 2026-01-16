package com.robot.core.info.pet.update
{
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.PetManager;
   import flash.utils.IDataInput;
   
   public class UpdatePropInfo
   {
      
      private var _catchTime:uint;
      
      private var _id:uint;
      
      private var _level:uint;
      
      private var _exp:uint;
      
      private var _maxHp:uint;
      
      private var _attack:uint;
      
      private var _defence:uint;
      
      private var _sa:uint;
      
      private var _sd:uint;
      
      private var _sp:uint;
      
      private var _ev_hp:uint;
      
      private var _ev_a:uint;
      
      private var _ev_d:uint;
      
      private var _ev_sa:uint;
      
      private var _ev_sd:uint;
      
      private var _ev_sp:uint;
      
      private var _currentLvExp:uint;
      
      private var _nextLvExp:uint;
      
      public function UpdatePropInfo(param1:IDataInput)
      {
         super();
         this._catchTime = param1.readUnsignedInt();
         this._id = param1.readUnsignedInt();
         this._level = param1.readUnsignedInt();
         this._exp = param1.readUnsignedInt();
         this._currentLvExp = param1.readUnsignedInt();
         this._nextLvExp = param1.readUnsignedInt();
         this._maxHp = param1.readUnsignedInt();
         this._attack = param1.readUnsignedInt();
         this._defence = param1.readUnsignedInt();
         this._sa = param1.readUnsignedInt();
         this._sd = param1.readUnsignedInt();
         this._sp = param1.readUnsignedInt();
         this._ev_hp = param1.readUnsignedInt();
         this._ev_a = param1.readUnsignedInt();
         this._ev_d = param1.readUnsignedInt();
         this._ev_sa = param1.readUnsignedInt();
         this._ev_sd = param1.readUnsignedInt();
         this._ev_sp = param1.readUnsignedInt();
      }
      
      public function update() : void
      {
         var _loc1_:PetInfo = null;
         _loc1_ = PetManager.getPetInfo(this._catchTime);
         _loc1_.id = this.id;
         _loc1_.level = this.level;
         _loc1_.maxHp = this.maxHp;
         _loc1_.attack = this.attack;
         _loc1_.defence = this.defence;
         _loc1_.s_a = this.sa;
         _loc1_.s_d = this.sd;
         _loc1_.speed = this.sp;
         _loc1_.exp = this.exp;
         _loc1_.nextLvExp = this.nextLvExp;
         _loc1_.lvExp = this.currentLvExp;
      }
      
      public function get catchTime() : uint
      {
         return this._catchTime;
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get level() : uint
      {
         return this._level;
      }
      
      public function get exp() : uint
      {
         return this._exp;
      }
      
      public function get currentLvExp() : uint
      {
         return this._currentLvExp;
      }
      
      public function get nextLvExp() : uint
      {
         return this._nextLvExp;
      }
      
      public function get maxHp() : uint
      {
         return this._maxHp;
      }
      
      public function get attack() : uint
      {
         return this._attack;
      }
      
      public function get defence() : uint
      {
         return this._defence;
      }
      
      public function get sa() : uint
      {
         return this._sa;
      }
      
      public function get sd() : uint
      {
         return this._sd;
      }
      
      public function get sp() : uint
      {
         return this._sp;
      }
   }
}

