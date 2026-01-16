package com.robot.core.info.skillEffectInfo
{
   public class Effect_447 extends AbstractEffectInfo
   {
      
      public function Effect_447()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "造成的伤害不少于" + param1[0];
      }
   }
}

