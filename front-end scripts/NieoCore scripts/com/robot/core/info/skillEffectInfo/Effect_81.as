package com.robot.core.info.skillEffectInfo
{
   public class Effect_81 extends AbstractEffectInfo
   {
      
      public function Effect_81()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内直接攻击必定命中";
      }
   }
}

