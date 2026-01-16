package com.robot.core.info.skillEffectInfo
{
   public class Effect_417 extends AbstractEffectInfo
   {
      
      public function Effect_417()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "使用后" + param1[0] + "回合内每次攻击造成伤害的" + param1[1] + "%都会恢复自身体力";
      }
   }
}

