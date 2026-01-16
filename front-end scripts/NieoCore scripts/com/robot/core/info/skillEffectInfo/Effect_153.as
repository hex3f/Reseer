package com.robot.core.info.skillEffectInfo
{
   public class Effect_153 extends AbstractEffectInfo
   {
      
      public function Effect_153()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每回合对对方造成伤害的1/" + param1[1] + "恢复自身体力";
      }
   }
}

