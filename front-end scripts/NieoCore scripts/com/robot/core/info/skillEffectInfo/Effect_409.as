package com.robot.core.info.skillEffectInfo
{
   public class Effect_409 extends AbstractEffectInfo
   {
      
      public function Effect_409()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，对手每回合速度和命中等级" + param1[1];
      }
   }
}

