package com.robot.core.info.skillEffectInfo
{
   public class Effect_411 extends AbstractEffectInfo
   {
      
      public function Effect_411()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加对手当前体力值" + param1[0] + "%的固定伤害，连续使用每次增加" + param1[1] + "%，最高" + param1[2] + "%";
      }
   }
}

