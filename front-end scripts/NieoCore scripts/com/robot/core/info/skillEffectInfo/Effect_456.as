package com.robot.core.info.skillEffectInfo
{
   public class Effect_456 extends AbstractEffectInfo
   {
      
      public function Effect_456()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手体力不足" + param1[0] + "则直接秒杀";
      }
   }
}

