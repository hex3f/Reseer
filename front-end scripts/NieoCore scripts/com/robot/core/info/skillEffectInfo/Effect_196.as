package com.robot.core.info.skillEffectInfo
{
   public class Effect_196 extends AbstractEffectInfo
   {
      
      public function Effect_196()
      {
         super();
         _argsNum = 6;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[1] + "%令对方" + propDict[param1[0]] + "等级" + param1[2] + "；若先出手，则" + param1[4] + "%使对方" + propDict[param1[3]] + "等级" + param1[5];
      }
   }
}

