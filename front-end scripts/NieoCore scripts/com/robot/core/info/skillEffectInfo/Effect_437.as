package com.robot.core.info.skillEffectInfo
{
   public class Effect_437 extends AbstractEffectInfo
   {
      
      public function Effect_437()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于能力强化状态，则对手" + propDict[param1[0]] + "等级" + param1[1];
      }
   }
}

