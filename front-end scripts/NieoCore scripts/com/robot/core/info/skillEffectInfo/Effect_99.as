package com.robot.core.info.skillEffectInfo
{
   public class Effect_99 extends AbstractEffectInfo
   {
      
      public function Effect_99()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时，" + param1[0] + "%几率令对手混乱";
      }
   }
}

