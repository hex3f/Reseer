package com.robot.core.info.skillEffectInfo
{
   public class Effect_170 extends AbstractEffectInfo
   {
      
      public function Effect_170()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若先出手，则免疫当回合伤害并回复1/" + param1[0] + "的最大体力值";
      }
   }
}

