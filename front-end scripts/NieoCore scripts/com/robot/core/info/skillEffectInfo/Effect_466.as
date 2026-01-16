package com.robot.core.info.skillEffectInfo
{
   public class Effect_466 extends AbstractEffectInfo
   {
      
      public function Effect_466()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "恢复" + param1[0] + "点体力";
      }
   }
}

