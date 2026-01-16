package com.robot.core.info.skillEffectInfo
{
   public class Effect_112 extends AbstractEffectInfo
   {
      
      public function Effect_112()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "牺牲全部体力给对手造成250~300点伤害，造成致命伤害时，对手剩下1点体力";
      }
   }
}

