package com.robot.app.petUpdate
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.PetManager;
   import flash.utils.ByteArray;
   
   public class ModifyPetManagerInfo
   {
      
      public function ModifyPetManagerInfo()
      {
         super();
      }
      
      public static function addSkill(param1:uint, param2:uint) : void
      {
         var _loc3_:PetInfo = PetManager.getPetInfo(param1);
         if(_loc3_.skillArray.length == 4)
         {
            throw new Error("宠物技能已经为四个，不能再手动添加技能");
         }
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeUnsignedInt(param2);
         _loc4_.writeUnsignedInt(SkillXMLInfo.getPP(param2));
         _loc4_.position = 0;
         _loc3_.skillArray.push(new PetSkillInfo(_loc4_));
      }
      
      public static function replaceSkill(param1:uint, param2:Array, param3:Array) : void
      {
         var _loc4_:Number = 0;
         var _loc5_:PetSkillInfo = null;
         var _loc6_:* = 0;
         var _loc7_:* = 0;
         var _loc8_:ByteArray = null;
         var _loc9_:PetInfo = PetManager.getPetInfo(param1);
         var _loc10_:Array = [];
         var _loc11_:Number = 0;
         for each(_loc4_ in param2)
         {
            _loc5_ = _loc9_.getSkillInfo(_loc4_);
            _loc6_ = uint(_loc9_.skillArray.indexOf(_loc5_));
            _loc7_ = uint(param3[_loc11_]);
            _loc8_ = new ByteArray();
            _loc8_.writeUnsignedInt(_loc7_);
            _loc8_.writeUnsignedInt(SkillXMLInfo.getPP(_loc7_));
            _loc8_.position = 0;
            _loc9_.skillArray[_loc6_] = new PetSkillInfo(_loc8_);
            _loc11_++;
         }
      }
   }
}

