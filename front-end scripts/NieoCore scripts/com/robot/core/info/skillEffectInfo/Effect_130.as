package com.robot.core.info.skillEffectInfo
{
   import com.robot.core.config.xml.PetXMLInfo;
   
   public class Effect_130 extends AbstractEffectInfo
   {
      
      public function Effect_130()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对方为" + PetXMLInfo.getPetGenderCN(param1[0]) + "则附加" + param1[1] + "点伤害";
      }
   }
}

