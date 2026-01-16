package com.robot.core.info.skillEffectInfo
{
   public class Effect_475 extends AbstractEffectInfo
   {
      
      public function Effect_475()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若造成的伤害不足" + param1[0] + "，则下" + param1[1] + "回合的攻击必定致命一击 ";
      }
   }
}

