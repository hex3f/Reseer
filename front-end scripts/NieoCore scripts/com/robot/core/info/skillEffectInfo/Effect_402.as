package com.robot.core.info.skillEffectInfo
{
   public class Effect_402 extends AbstractEffectInfo
   {
      
      public function Effect_402()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "后出手时，额外附加" + param1[0] + "点固定伤害";
      }
   }
}

