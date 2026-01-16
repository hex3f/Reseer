package com.robot.core.info.skillEffectInfo
{
   public class Effect_419 extends AbstractEffectInfo
   {
      
      public function Effect_419()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手处于能力强化状态，则每回合都会受到" + param1[1] + "点固定伤害";
      }
   }
}

