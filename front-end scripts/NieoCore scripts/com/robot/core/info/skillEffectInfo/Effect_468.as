package com.robot.core.info.skillEffectInfo
{
   public class Effect_468 extends AbstractEffectInfo
   {
      
      public function Effect_468()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "回合开始时，若自身处于能力下降状态，则威力翻倍，同时解除能力下降状态";
      }
   }
}

