package com.robot.core.info.skillEffectInfo
{
   public class Effect_12 extends AbstractEffectInfo
   {
      
      public function Effect_12()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时，有" + param1[0] + "%几率令对方陷入烧伤状态";
      }
   }
}

