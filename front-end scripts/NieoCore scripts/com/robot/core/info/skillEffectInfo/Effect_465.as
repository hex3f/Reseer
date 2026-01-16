package com.robot.core.info.skillEffectInfo
{
   public class Effect_465 extends AbstractEffectInfo
   {
      
      public function Effect_465()
      {
         super();
         _argsNum = 4;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%令对手疲惫" + param1[1] + "回合，每次使用几率提升" + param1[2] + "%，最高" + param1[3] + "%";
      }
   }
}

