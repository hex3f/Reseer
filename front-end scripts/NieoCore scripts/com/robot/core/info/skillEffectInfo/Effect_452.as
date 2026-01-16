package com.robot.core.info.skillEffectInfo
{
   public class Effect_452 extends AbstractEffectInfo
   {
      
      public function Effect_452()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "合内自身所有攻击造成的伤害都将为自己恢复体力";
      }
   }
}

