package com.robot.core.info.skillEffectInfo
{
   public class Effect_109 extends AbstractEffectInfo
   {
      
      public function Effect_109()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，给对手造成伤害时，有" + param1[1] + "%几率令对手冻伤";
      }
   }
}

