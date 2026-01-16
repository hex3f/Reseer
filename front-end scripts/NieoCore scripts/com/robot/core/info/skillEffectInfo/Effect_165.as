package com.robot.core.info.skillEffectInfo
{
   public class Effect_165 extends AbstractEffectInfo
   {
      
      public function Effect_165()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每回合防御和特防等级+" + param1[1];
      }
   }
}

