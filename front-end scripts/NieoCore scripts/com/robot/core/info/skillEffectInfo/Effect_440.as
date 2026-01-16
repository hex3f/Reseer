package com.robot.core.info.skillEffectInfo
{
   public class Effect_440 extends AbstractEffectInfo
   {
      
      public function Effect_440()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内对手释放技能所消耗的PP为" + param1[1] + "倍";
      }
   }
}

