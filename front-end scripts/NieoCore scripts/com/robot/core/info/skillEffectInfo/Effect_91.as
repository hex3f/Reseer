package com.robot.core.info.skillEffectInfo
{
   public class Effect_91 extends AbstractEffectInfo
   {
      
      public function Effect_91()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，对手的状态变化会同时作用在自己身上";
      }
   }
}

