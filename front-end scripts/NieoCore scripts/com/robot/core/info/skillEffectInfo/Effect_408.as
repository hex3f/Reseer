package com.robot.core.info.skillEffectInfo
{
   public class Effect_408 extends AbstractEffectInfo
   {
      
      public function Effect_408()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每回合所受的伤害减少" + param1[1];
      }
   }
}

