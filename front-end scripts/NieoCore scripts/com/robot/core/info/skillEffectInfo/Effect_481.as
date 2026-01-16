package com.robot.core.info.skillEffectInfo
{
   public class Effect_481 extends AbstractEffectInfo
   {
      
      public function Effect_481()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "下" + param1[0] + "回合自身攻击先制+" + param1[1];
      }
   }
}

