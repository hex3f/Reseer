package com.robot.core.info.skillEffectInfo
{
   public class Effect_64 extends AbstractEffectInfo
   {
      
      public function Effect_64()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "自身处于烧伤·冻伤·中毒状态的场合，造成的伤害增加100%";
      }
   }
}

