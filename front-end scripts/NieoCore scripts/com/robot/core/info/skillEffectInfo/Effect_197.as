package com.robot.core.info.skillEffectInfo
{
   public class Effect_197 extends AbstractEffectInfo
   {
      
      public function Effect_197()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内若被对方击败，则对手所有能力加强状态消失";
      }
   }
}

