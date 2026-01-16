package com.robot.core.info.skillEffectInfo
{
   public class Effect_9 extends AbstractEffectInfo
   {
      
      public function Effect_9()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "连续使用时，每次的[威力]增加" + param1[0] + "，最高[威力]增加" + param1[1];
      }
   }
}

