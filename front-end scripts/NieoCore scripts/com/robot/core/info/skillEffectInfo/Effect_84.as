package com.robot.core.info.skillEffectInfo
{
   public class Effect_84 extends AbstractEffectInfo
   {
      
      public function Effect_84()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内受到物理攻击时有" + param1[1] + "%几率将对手麻痹";
      }
   }
}

