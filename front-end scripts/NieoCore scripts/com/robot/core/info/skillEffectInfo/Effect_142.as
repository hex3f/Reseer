package com.robot.core.info.skillEffectInfo
{
   public class Effect_142 extends AbstractEffectInfo
   {
      
      public function Effect_142()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "损失1/" + param1[0] + "的体力值，下回合能较快出手";
      }
   }
}

