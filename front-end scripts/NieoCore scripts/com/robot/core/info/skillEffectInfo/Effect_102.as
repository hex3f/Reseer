package com.robot.core.info.skillEffectInfo
{
   public class Effect_102 extends AbstractEffectInfo
   {
      
      public function Effect_102()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对手处于麻痹状态时，威力翻倍";
      }
   }
}

