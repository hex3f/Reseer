package com.robot.core.info.skillEffectInfo
{
   public class Effect_413 extends AbstractEffectInfo
   {
      
      public function Effect_413()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于能力强化状态则附加" + param1[0] + "点固定伤害";
      }
   }
}

