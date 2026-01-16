package com.robot.core.info.skillEffectInfo
{
   import com.robot.core.config.xml.*;
   
   public class Effect_65 extends AbstractEffectInfo
   {
      
      public function Effect_65()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(Boolean(param1[2] % 1))
         {
            return param1[0] + "回合内，自身" + SkillXMLInfo.getTypeCNBytTypeID(uint(param1[1])) + "系技能的[威力]增加" + (param1[2] - 1) * 100 + "%";
         }
         return param1[0] + "回合内，自身" + SkillXMLInfo.getTypeCNBytTypeID(uint(param1[1])) + "系技能的[威力]增加" + (param1[2] - 1) + "00%";
      }
   }
}

