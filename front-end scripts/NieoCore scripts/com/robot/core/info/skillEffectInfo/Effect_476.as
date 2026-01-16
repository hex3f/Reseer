package com.robot.core.info.skillEffectInfo
{
   public class Effect_476 extends AbstractEffectInfo
   {
      
      public function Effect_476()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "后出手时恢复" + param1[0] + "点体力";
      }
   }
}

