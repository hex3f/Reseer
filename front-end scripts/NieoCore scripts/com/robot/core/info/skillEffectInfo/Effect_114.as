package com.robot.core.info.skillEffectInfo
{
   public class Effect_114 extends AbstractEffectInfo
   {
      
      public function Effect_114()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中后有" + param1[0] + "%几率令对方易燃";
      }
   }
}

