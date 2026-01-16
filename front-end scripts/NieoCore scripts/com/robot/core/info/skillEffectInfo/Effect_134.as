package com.robot.core.info.skillEffectInfo
{
   public class Effect_134 extends AbstractEffectInfo
   {
      
      public function Effect_134()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若造成的伤害低于" + param1[0] + "，则所有技能的PP值提高" + param1[1] + "点";
      }
   }
}

