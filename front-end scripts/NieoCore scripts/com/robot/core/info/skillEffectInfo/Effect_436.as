package com.robot.core.info.skillEffectInfo
{
   public class Effect_436 extends AbstractEffectInfo
   {
      
      public function Effect_436()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加已损失体力值" + param1[0] + "%的固定伤害";
      }
   }
}

