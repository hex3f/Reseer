package com.robot.core.info.skillEffectInfo
{
   public class Effect_192 extends AbstractEffectInfo
   {
      
      public function Effect_192()
      {
         super();
         _argsNum = 10;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加" + param1[0] + "%当前体力值的伤害";
      }
   }
}

