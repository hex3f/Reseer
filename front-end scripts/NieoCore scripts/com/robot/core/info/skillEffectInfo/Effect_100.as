package com.robot.core.info.skillEffectInfo
{
   public class Effect_100 extends AbstractEffectInfo
   {
      
      public function Effect_100()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "自身体力越少则威力越大";
      }
   }
}

