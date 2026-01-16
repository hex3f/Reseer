package com.robot.core.info.skillEffectInfo
{
   public class Effect_92 extends AbstractEffectInfo
   {
      
      public function Effect_92()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，受到物理攻击时，有" + param1[1] + "%几率将对手冻伤";
      }
   }
}

