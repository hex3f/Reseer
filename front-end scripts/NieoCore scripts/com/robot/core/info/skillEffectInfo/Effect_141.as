package com.robot.core.info.skillEffectInfo
{
   public class Effect_141 extends AbstractEffectInfo
   {
      
      public function Effect_141()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对方处于冻伤状态时，附加" + param1[0] + "点伤害";
      }
   }
}

