package com.robot.core.info.skillEffectInfo
{
   public class Effect_415 extends AbstractEffectInfo
   {
      
      public function Effect_415()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若造成的伤害大于" + param1[0] + "点，则自身恢复" + param1[1] + "点生命值";
      }
   }
}

