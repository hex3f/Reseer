package com.robot.core.info.skillEffectInfo
{
   public class Effect_36 extends AbstractEffectInfo
   {
      
      public function Effect_36()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时，有" + param1[0] + "%的几率秒杀对方";
      }
   }
}

