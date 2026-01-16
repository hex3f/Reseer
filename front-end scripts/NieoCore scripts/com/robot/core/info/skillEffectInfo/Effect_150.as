package com.robot.core.info.skillEffectInfo
{
   public class Effect_150 extends AbstractEffectInfo
   {
      
      public function Effect_150()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，对手每回合防御和特防等级" + param1[1];
      }
   }
}

