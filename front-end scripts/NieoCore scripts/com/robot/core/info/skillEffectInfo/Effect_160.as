package com.robot.core.info.skillEffectInfo
{
   public class Effect_160 extends AbstractEffectInfo
   {
      
      public function Effect_160()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手MISS则下回合自身必定致命一击";
      }
   }
}

