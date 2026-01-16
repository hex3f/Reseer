package com.robot.core.info.skillEffectInfo
{
   public class Effect_132 extends AbstractEffectInfo
   {
      
      public function Effect_132()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若当前HP低于对手，则技能威力翻倍";
      }
   }
}

