package com.robot.core.info.skillEffectInfo
{
   public class Effect_55 extends AbstractEffectInfo
   {
      
      public function Effect_55()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，令自身的属性与对方交换";
      }
   }
}

