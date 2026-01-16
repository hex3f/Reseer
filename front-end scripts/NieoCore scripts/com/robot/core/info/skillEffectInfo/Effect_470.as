package com.robot.core.info.skillEffectInfo
{
   public class Effect_470 extends AbstractEffectInfo
   {
      
      public function Effect_470()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内每次攻击都有" + param1[1] + "%几率另对手" + statusDict[param1[2]];
      }
   }
}

