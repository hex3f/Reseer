package com.robot.core.info.skillEffectInfo
{
   public class Effect_145 extends AbstractEffectInfo
   {
      
      public function Effect_145()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "攻击中毒的对手时，自身回复1/" + param1[0] + "最大体力值";
      }
   }
}

