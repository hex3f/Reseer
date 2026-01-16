package com.robot.core.info.skillEffectInfo
{
   public class Effect_687 extends AbstractEffectInfo
   {
      
      public function Effect_687()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手" + statusDict[param1[0]] + "，则对对方造成伤害的" + param1[1] + "恢复自身体力";
      }
   }
}

