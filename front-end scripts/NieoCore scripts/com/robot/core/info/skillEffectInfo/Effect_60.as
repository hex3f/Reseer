package com.robot.core.info.skillEffectInfo
{
   public class Effect_60 extends AbstractEffectInfo
   {
      
      public function Effect_60()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，令对手每回合受到" + param1[1] + "点[固定伤害]";
      }
   }
}

