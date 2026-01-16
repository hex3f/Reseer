package com.robot.core.info.skillEffectInfo
{
   public class Effect_439 extends AbstractEffectInfo
   {
      
      public function Effect_439()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若自身处于能力下降或异常状态，则对手每回合受到" + param1[1] + "点固定伤害";
      }
   }
}

