package com.robot.core.info.skillEffectInfo
{
   public class Effect_127 extends AbstractEffectInfo
   {
      
      public function Effect_127()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%的概率，" + param1[1] + "回合内受到的伤害减半";
      }
   }
}

