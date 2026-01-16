package com.robot.core.info.skillEffectInfo
{
   public class Effect_474 extends AbstractEffectInfo
   {
      
      public function Effect_474()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "先出手时" + param1[1] + "%自身" + propDict[param1[0]] + "等级+" + param1[2];
      }
   }
}

