package com.robot.core.info.skillEffectInfo
{
   public class Effect_407 extends AbstractEffectInfo
   {
      
      public function Effect_407()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "下回合起，每回合" + propDict[param1[0]] + "等级+" + param1[1] + "，持续" + param1[2] + "回合";
      }
   }
}

