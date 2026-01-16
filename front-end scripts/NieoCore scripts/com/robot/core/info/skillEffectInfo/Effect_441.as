package com.robot.core.info.skillEffectInfo
{
   public class Effect_441 extends AbstractEffectInfo
   {
      
      public function Effect_441()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "每次攻击提升" + param1[0] + "%的致命几率，最高提升" + param1[1] + "%";
      }
   }
}

