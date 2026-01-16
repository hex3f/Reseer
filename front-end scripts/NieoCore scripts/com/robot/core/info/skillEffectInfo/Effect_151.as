package com.robot.core.info.skillEffectInfo
{
   public class Effect_151 extends AbstractEffectInfo
   {
      
      public function Effect_151()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对手烧伤时，" + param1[0] + "%对方疲惫1回合；对手未烧伤时，" + param1[1] + "%对方疲惫1回合";
      }
   }
}

