package com.robot.core.info.skillEffectInfo
{
   public class Effect_416 extends AbstractEffectInfo
   {
      
      public function Effect_416()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，受到任何伤害，对手" + propDict[param1[1]] + "降低" + param1[2] + "个等级";
      }
   }
}

