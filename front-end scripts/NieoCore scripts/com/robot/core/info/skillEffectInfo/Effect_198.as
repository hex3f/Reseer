package com.robot.core.info.skillEffectInfo
{
   public class Effect_198 extends AbstractEffectInfo
   {
      
      public function Effect_198()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "随机使对手" + param1[0] + "种能力等级-" + param1[1];
      }
   }
}

