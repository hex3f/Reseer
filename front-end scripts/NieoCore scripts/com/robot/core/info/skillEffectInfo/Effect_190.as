package com.robot.core.info.skillEffectInfo
{
   public class Effect_190 extends AbstractEffectInfo
   {
      
      public function Effect_190()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若受到攻击，消除对手所有能力强化状态";
      }
   }
}

