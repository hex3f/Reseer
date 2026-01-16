package com.robot.core.info.skillEffectInfo
{
   public class Effect_133 extends AbstractEffectInfo
   {
      
      public function Effect_133()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对方烧伤时，附加" + param1[0] + "点伤害";
      }
   }
}

