package com.robot.core.info.skillEffectInfo
{
   public class Effect_454 extends AbstractEffectInfo
   {
      
      public function Effect_454()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "当自身血量少于1/" + param1[0] + "时先制+" + param1[1];
      }
   }
}

