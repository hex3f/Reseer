package com.robot.core.info.skillEffectInfo
{
   public class Effect_432 extends AbstractEffectInfo
   {
      
      public function Effect_432()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内对手所有攻击必定MISS，必中技能有效";
      }
   }
}

