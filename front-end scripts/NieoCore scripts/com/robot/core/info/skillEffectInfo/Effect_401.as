package com.robot.core.info.skillEffectInfo
{
   public class Effect_401 extends AbstractEffectInfo
   {
      
      public function Effect_401()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若和对手属性相同，则技能威力翻倍";
      }
   }
}

