package com.robot.core.info.skillEffectInfo
{
   public class Effect_186 extends AbstractEffectInfo
   {
      
      public function Effect_186()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "后出手时，" + param1[1] + "%使自身" + propDict[param1[0]] + "提升" + param1[2] + "个等级";
      }
   }
}

