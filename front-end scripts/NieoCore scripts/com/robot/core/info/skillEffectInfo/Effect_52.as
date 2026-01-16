package com.robot.core.info.skillEffectInfo
{
   public class Effect_52 extends AbstractEffectInfo
   {
      
      public function Effect_52()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "先手使用且自身速度大于对方的场合，令对方的下1个技能失效";
      }
   }
}

