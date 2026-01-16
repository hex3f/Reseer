package com.robot.core.info.skillEffectInfo
{
   public class Effect_429 extends AbstractEffectInfo
   {
      
      public function Effect_429()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加" + param1[0] + "点固定伤害，连续使用每次增加" + param1[1] + "点固定伤害，最高附加" + param1[2] + "点固定伤害";
      }
   }
}

