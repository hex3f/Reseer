package com.robot.core.info.skillEffectInfo
{
   public class Effect_508 extends AbstractEffectInfo
   {
      
      public function Effect_508()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "减少" + param1[0] + "点下回合所受的伤害 ";
      }
   }
}

