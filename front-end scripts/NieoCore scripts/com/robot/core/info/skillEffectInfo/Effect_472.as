package com.robot.core.info.skillEffectInfo
{
   public class Effect_472 extends AbstractEffectInfo
   {
      
      public function Effect_472()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于" + statusDict[param1[0]] + "状态则每次攻击造成的伤害都将恢复自身体力";
      }
   }
}

