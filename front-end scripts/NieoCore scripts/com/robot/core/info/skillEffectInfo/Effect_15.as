package com.robot.core.info.skillEffectInfo
{
   public class Effect_15 extends AbstractEffectInfo
   {
      
      public function Effect_15()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时，有" + param1[0] + "%几率令对方陷入害怕状态";
      }
   }
}

