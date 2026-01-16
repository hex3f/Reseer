package com.robot.core.info.skillEffectInfo
{
   public class Effect_53 extends AbstractEffectInfo
   {
      
      public function Effect_53()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(Boolean(param1[1] % 1))
         {
            return param1[0] + "回合内，令自身的攻击伤害增加" + (param1[1] - 1) * 100 + "%";
         }
         return param1[0] + "回合内，令自身的攻击伤害增加" + (param1[1] - 1) + "00%";
      }
   }
}

