package com.robot.core.info.pet
{
   import flash.utils.Dictionary;
   import flash.utils.IDataInput;
   
   public class PetInfo
   {
      
      public var id:uint;
      
      public var name:String;
      
      public var isDefault:Boolean = false;
      
      public var dv:uint;
      
      public var nature:uint;
      
      public var level:uint;
      
      public var exp:uint;
      
      public var lvExp:uint;
      
      public var nextLvExp:uint;
      
      public var hp:uint;
      
      public var maxHp:uint;
      
      public var attack:uint;
      
      public var defence:uint;
      
      public var s_a:uint;
      
      public var s_d:uint;
      
      public var speed:uint;
      
      public var ev_hp:uint;
      
      public var ev_attack:uint;
      
      public var ev_defence:uint;
      
      public var ev_sa:uint;
      
      public var ev_sd:uint;
      
      public var ev_sp:uint;
      
      public var skillNum:uint;
      
      public var skillArray:Array;
      
      public var catchTime:uint;
      
      public var catchMap:uint;
      
      public var catchRect:uint;
      
      public var catchLevel:uint;
      
      private var dict:Dictionary;
      
      public var effectCount:uint;
      
      public var effectList:Array;
      
      public var generation:uint;
      
      public var skinID:uint;
      
      public function PetInfo(param1:IDataInput, param2:Boolean = true)
      {
         var _loc5_:Number = NaN;
         var _loc3_:PetSkillInfo = null;
         this.skillArray = [];
         this.dict = new Dictionary();
         this.effectList = [];
         super();
         this.id = param1.readUnsignedInt();
         if(param2)
         {
            this.name = param1.readUTFBytes(16);
            this.dv = param1.readUnsignedInt();
            this.nature = param1.readUnsignedInt();
            this.level = param1.readUnsignedInt();
            this.exp = param1.readUnsignedInt();
            this.lvExp = param1.readUnsignedInt();
            this.nextLvExp = param1.readUnsignedInt();
            this.hp = param1.readUnsignedInt();
            this.maxHp = param1.readUnsignedInt();
            this.attack = param1.readUnsignedInt();
            this.defence = param1.readUnsignedInt();
            this.s_a = param1.readUnsignedInt();
            this.s_d = param1.readUnsignedInt();
            this.speed = param1.readUnsignedInt();
            this.ev_hp = param1.readUnsignedInt();
            this.ev_attack = param1.readUnsignedInt();
            this.ev_defence = param1.readUnsignedInt();
            this.ev_sa = param1.readUnsignedInt();
            this.ev_sd = param1.readUnsignedInt();
            this.ev_sp = param1.readUnsignedInt();
         }
         else
         {
            this.level = param1.readUnsignedInt();
            this.hp = param1.readUnsignedInt();
            this.maxHp = param1.readUnsignedInt();
         }
         this.skillNum = param1.readUnsignedInt();
         var _loc4_:int = 0;
         while(_loc4_ < 4)
         {
            _loc3_ = new PetSkillInfo(param1);
            if(_loc3_.id != 0)
            {
               this.skillArray.push(_loc3_);
               this.dict[_loc3_.id] = _loc3_;
            }
            _loc4_++;
         }
         this.skillArray = this.skillArray.slice(0,this.skillNum);
         this.catchTime = param1.readUnsignedInt();
         this.catchMap = param1.readUnsignedInt();
         this.catchRect = param1.readUnsignedInt();
         this.catchLevel = param1.readUnsignedInt();
         if(param2)
         {
            this.effectCount = param1.readUnsignedShort();
            _loc5_ = 0;
            while(_loc5_ < this.effectCount)
            {
               this.effectList.push(new PetEffectInfo(param1));
               _loc5_++;
            }
         }
         this.generation = 0;
         this.skinID = param1.readUnsignedInt();
      }
      
      public function getSkillInfo(param1:uint) : PetSkillInfo
      {
         return this.dict[param1];
      }
      
      public function get allPP() : uint
      {
         var _loc1_:PetSkillInfo = null;
         var _loc2_:* = 0;
         for each(_loc1_ in this.skillArray)
         {
            _loc2_ += _loc1_.pp;
         }
         return _loc2_;
      }
   }
}

