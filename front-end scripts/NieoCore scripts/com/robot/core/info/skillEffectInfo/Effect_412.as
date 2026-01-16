package com.robot.core.info.skillEffectInfo
{
   public class Effect_412 extends AbstractEffectInfo
   {
      
      public function Effect_412()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若自身体力小于1/" + param1[0] + "，则每次攻击不消耗PP值";
      }
   }
}

