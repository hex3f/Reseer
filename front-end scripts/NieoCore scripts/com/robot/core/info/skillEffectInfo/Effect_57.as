package com.robot.core.info.skillEffectInfo
{
   public class Effect_57 extends AbstractEffectInfo
   {
      
      public function Effect_57()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，自身每回合回复[最大体力]的1/" + param1[1];
      }
   }
}

