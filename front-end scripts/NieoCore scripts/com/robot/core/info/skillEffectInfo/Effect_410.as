package com.robot.core.info.skillEffectInfo
{
   public class Effect_410 extends AbstractEffectInfo
   {
      
      public function Effect_410()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%回复自身1/" + param1[1] + "体力值";
      }
   }
}

