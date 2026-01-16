package com.robot.core.info.skillEffectInfo
{
   public class Effect_80 extends AbstractEffectInfo
   {
      
      public function Effect_80()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "损失1/2的体力，给予对手同等的伤害";
      }
   }
}

