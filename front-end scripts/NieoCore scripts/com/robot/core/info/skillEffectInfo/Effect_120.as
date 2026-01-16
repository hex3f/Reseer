package com.robot.core.info.skillEffectInfo
{
   public class Effect_120 extends AbstractEffectInfo
   {
      
      public function Effect_120()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "50%几率对方减血1/" + param1[0] + "，50%几率自己减血1/" + param1[0];
      }
   }
}

