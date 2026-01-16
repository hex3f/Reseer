package com.robot.core.info.skillEffectInfo
{
   public class Effect_430 extends AbstractEffectInfo
   {
      
      public function Effect_430()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "消除对手能力强化状态，若消除状态成功，则自身" + propDict[param1[0]] + "等级" + param1[1];
      }
   }
}

