package com.robot.core.info.skillEffectInfo
{
   public class Effect_126 extends AbstractEffectInfo
   {
      
      public function Effect_126()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每回合自身攻击和速度提高" + param1[1] + "个等级";
      }
   }
}

