package com.robot.core.info.skillEffectInfo
{
   public class Effect_155 extends AbstractEffectInfo
   {
      
      public function Effect_155()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "恢复全部体力，消除所有能力下降，使自己进入睡眠" + param1[0] + "回合";
      }
   }
}

