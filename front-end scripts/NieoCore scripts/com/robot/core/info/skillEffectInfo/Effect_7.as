package com.robot.core.info.skillEffectInfo
{
   public class Effect_7 extends AbstractEffectInfo
   {
      
      public function Effect_7()
      {
         super();
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对方体力高于自身时才能命中，给予对方相当于双方体力差值的[固定伤害]";
      }
   }
}

