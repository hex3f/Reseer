package com.robot.core.info.skillEffectInfo
{
   public class Effect_449 extends AbstractEffectInfo
   {
      
      public function Effect_449()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于能力下降状态则" + param1[0] + "%几率" + statusDict[param1[1]];
      }
   }
}

