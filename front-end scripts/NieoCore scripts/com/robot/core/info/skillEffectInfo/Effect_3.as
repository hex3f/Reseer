package com.robot.core.info.skillEffectInfo
{
   public class Effect_3 extends AbstractEffectInfo
   {
      
      public function Effect_3()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "解除自身所有的能力下降状态";
      }
   }
}

