package com.robot.core.info.skillEffectInfo
{
   public class Effect_464 extends AbstractEffectInfo
   {
      
      public function Effect_464()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "遇到天敌时" + param1[0] + "%令对手烧伤";
      }
   }
}

