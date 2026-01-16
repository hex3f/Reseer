package com.robot.core.info.skillEffectInfo
{
   public class Effect_463 extends AbstractEffectInfo
   {
      
      public function Effect_463()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内每回合所受的伤害减少" + param1[1] + "点";
      }
   }
}

