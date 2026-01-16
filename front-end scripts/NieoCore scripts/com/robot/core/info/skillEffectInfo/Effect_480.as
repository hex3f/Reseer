package com.robot.core.info.skillEffectInfo
{
   public class Effect_480 extends AbstractEffectInfo
   {
      
      public function Effect_480()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内自身所有攻击威力为两倍";
      }
   }
}

