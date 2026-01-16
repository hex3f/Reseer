package com.robot.core.info.skillEffectInfo
{
   public class Effect_123 extends AbstractEffectInfo
   {
      
      public function Effect_123()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，受到任何伤害，自身" + propDict[param1[1]] + "提高" + param1[2] + "个等级";
      }
   }
}

