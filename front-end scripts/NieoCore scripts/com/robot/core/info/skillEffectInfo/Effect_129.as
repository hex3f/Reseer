package com.robot.core.info.skillEffectInfo
{
   import com.robot.core.config.xml.PetXMLInfo;
   
   public class Effect_129 extends AbstractEffectInfo
   {
      
      public function Effect_129()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对方为" + PetXMLInfo.getPetGenderCN(param1[0]) + "则技能威力翻倍";
      }
   }
}

