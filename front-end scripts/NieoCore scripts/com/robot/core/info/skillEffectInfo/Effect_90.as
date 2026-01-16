package com.robot.core.info.skillEffectInfo
{
   public class Effect_90 extends AbstractEffectInfo
   {
      
      public function Effect_90()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，自身造成的伤害为" + param1[1] + "倍 ";
      }
   }
}

