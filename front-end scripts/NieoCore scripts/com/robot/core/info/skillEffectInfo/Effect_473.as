package com.robot.core.info.skillEffectInfo
{
   public class Effect_473 extends AbstractEffectInfo
   {
      
      public function Effect_473()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若造成的伤害不足" + param1[0] + "，则自身" + propDict[param1[1]] + "等级+" + param1[2];
      }
   }
}

