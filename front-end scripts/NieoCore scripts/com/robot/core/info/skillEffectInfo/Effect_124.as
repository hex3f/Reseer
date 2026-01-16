package com.robot.core.info.skillEffectInfo
{
   public class Effect_124 extends AbstractEffectInfo
   {
      
      public function Effect_124()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中后，" + param1[0] + "%几率随机降低对方一个属性" + Math.abs(param1[1]) + "个等级";
      }
   }
}

