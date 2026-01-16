package com.robot.core.info.skillEffectInfo
{
   public class Effect_426 extends AbstractEffectInfo
   {
      
      public function Effect_426()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内有" + param1[1] + "%的几率回避对手攻击";
      }
   }
}

