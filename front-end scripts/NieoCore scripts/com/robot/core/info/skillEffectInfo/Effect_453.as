package com.robot.core.info.skillEffectInfo
{
   public class Effect_453 extends AbstractEffectInfo
   {
      
      public function Effect_453()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "消除对手能力强化状态，若消除成功，则对手" + statusDict[param1[0]];
      }
   }
}

