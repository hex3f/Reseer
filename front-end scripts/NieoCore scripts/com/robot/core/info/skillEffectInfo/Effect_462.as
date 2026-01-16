package com.robot.core.info.skillEffectInfo
{
   public class Effect_462 extends AbstractEffectInfo
   {
      
      public function Effect_462()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内受攻击时反弹" + param1[1] + "点固定伤害";
      }
   }
}

