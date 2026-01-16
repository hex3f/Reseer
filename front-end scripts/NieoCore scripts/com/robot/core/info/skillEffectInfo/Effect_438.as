package com.robot.core.info.skillEffectInfo
{
   public class Effect_438 extends AbstractEffectInfo
   {
      
      public function Effect_438()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%的几率恢复自身体力的1/" + param1[1];
      }
   }
}

