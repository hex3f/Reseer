package com.robot.core.info.skillEffectInfo
{
   public class Effect_44 extends AbstractEffectInfo
   {
      
      public function Effect_44()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，自身受到[特殊攻击]伤害减少50%";
      }
   }
}

