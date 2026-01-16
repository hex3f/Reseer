package com.robot.core.info.skillEffectInfo
{
   public class Effect_467 extends AbstractEffectInfo
   {
      
      public function Effect_467()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于" + statusDict[param1[0]] + "状态则附加" + param1[1] + "点固定伤害 ";
      }
   }
}

