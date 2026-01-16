package com.robot.core.info
{
   import com.robot.core.info.pet.PetEffectInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import flash.utils.IDataInput;
   
   public class RoomPetInfo
   {
      
      public var ownerId:uint;
      
      public var catchTime:uint;
      
      public var id:uint;
      
      public var nature:uint;
      
      public var lv:uint;
      
      public var hp:uint;
      
      public var atk:uint;
      
      public var def:uint;
      
      public var spatk:uint;
      
      public var spdef:uint;
      
      public var speed:uint;
      
      public var skillNum:uint;
      
      public var skillInfoArr:Array;
      
      public var len:int;
      
      public var evValueA:Array;
      
      public var effNum:uint;
      
      public var effA:Array;
      
      public function RoomPetInfo(param1:IDataInput = null)
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:PetSkillInfo = null;
         this.skillInfoArr = [];
         super();
         if(Boolean(param1))
         {
            this.ownerId = param1.readUnsignedInt();
            this.catchTime = param1.readUnsignedInt();
            this.id = param1.readUnsignedInt();
            this.nature = param1.readUnsignedInt();
            this.lv = param1.readUnsignedInt();
            this.hp = param1.readUnsignedInt();
            this.atk = param1.readUnsignedInt();
            this.def = param1.readUnsignedInt();
            this.spatk = param1.readUnsignedInt();
            this.spdef = param1.readUnsignedInt();
            this.speed = param1.readUnsignedInt();
            this.skillNum = param1.readUnsignedInt();
            this.skillInfoArr = new Array();
            this.len = Math.min(this.skillNum,4);
            _loc2_ = 0;
            while(_loc2_ < this.len)
            {
               _loc5_ = new PetSkillInfo(param1);
               if(_loc5_.id != 0)
               {
                  this.skillInfoArr.push(_loc5_);
               }
               _loc2_++;
            }
            this.evValueA = new Array();
            _loc3_ = 0;
            while(_loc3_ < 6)
            {
               this.evValueA.push(param1.readUnsignedInt());
               _loc3_++;
            }
            this.effNum = param1.readUnsignedShort();
            this.effA = new Array();
            _loc4_ = 0;
            while(_loc4_ < this.effNum)
            {
               this.effA.push(new PetEffectInfo(param1));
               _loc4_++;
            }
         }
      }
   }
}

