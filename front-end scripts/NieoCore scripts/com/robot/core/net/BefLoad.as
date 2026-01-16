package com.robot.core.net
{
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.StringUtil;
   
   public class BefLoad extends BaseBeanController
   {
      
      private static const PET_PATH:String = "resource/fightResource/pet/swf/";
      
      private static const SKILL_PATH:String = "resource/fightResource/skill/swf/";
      
      public function BefLoad()
      {
         super();
      }
      
      override public function start() : void
      {
         var _loc1_:PetInfo = null;
         var _loc2_:Array = null;
         var _loc3_:PetSkillInfo = null;
         var _loc4_:Array = PetManager.infos;
         for each(_loc1_ in _loc4_)
         {
            ResourceManager.addBef(PET_PATH + StringUtil.renewZero(_loc1_.id.toString(),3) + ".swf","pet",false);
            _loc2_ = _loc1_.skillArray;
            for each(_loc3_ in _loc2_)
            {
               ResourceManager.addBef(SKILL_PATH + _loc3_.id.toString() + ".swf","skill",false);
            }
         }
         finish();
      }
   }
}

