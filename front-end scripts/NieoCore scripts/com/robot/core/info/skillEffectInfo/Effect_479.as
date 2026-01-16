package com.robot.core.info.skillEffectInfo
{
   public class Effect_479 extends AbstractEffectInfo
   {
      
      public function Effect_479()
      {
         super();
         _argsNum = 4;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "损失自身" + param1[0] + "点体力，给对手造成" + param1[1] + "点固定伤害，若自身体力不足" + param1[2] + "则剩下" + param1[3] + "点体力";
      }
   }
}

