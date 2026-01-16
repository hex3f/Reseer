package com.robot.core.info.skillEffectInfo
{
   public class Effect_1 extends AbstractEffectInfo
   {
      
      public function Effect_1()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时，自身回复相当于该技能造成伤害50%的体力";
      }
   }
}

