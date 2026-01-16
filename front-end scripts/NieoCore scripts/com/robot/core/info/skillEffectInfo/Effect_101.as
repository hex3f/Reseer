package com.robot.core.info.skillEffectInfo
{
   public class Effect_101 extends AbstractEffectInfo
   {
      
      public function Effect_101()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "给对手造成伤害时，伤害数值的" + param1[0] + "%恢复自身体力";
      }
   }
}

