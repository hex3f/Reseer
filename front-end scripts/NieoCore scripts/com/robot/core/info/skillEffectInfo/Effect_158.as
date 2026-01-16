package com.robot.core.info.skillEffectInfo
{
   public class Effect_158 extends AbstractEffectInfo
   {
      
      public function Effect_158()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "当次攻击击败对手，则" + param1[1] + "%改变自身" + propDict[param1[0]] + "等级+" + param1[2];
      }
   }
}

