package com.robot.core.info.skillEffectInfo
{
   public class Effect_428 extends AbstractEffectInfo
   {
      
      public function Effect_428()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "遇到天敌时附加" + param1[0] + "点固定伤害";
      }
   }
}

