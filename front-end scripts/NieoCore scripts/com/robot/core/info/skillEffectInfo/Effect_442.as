package com.robot.core.info.skillEffectInfo
{
   public class Effect_442 extends AbstractEffectInfo
   {
      
      public function Effect_442()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%另对手" + statusDict[param1[1]] + "，每次造成的伤害值都将恢复自身体力";
      }
   }
}

