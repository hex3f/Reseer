package com.robot.core.info.skillEffectInfo
{
   public class Effect_156 extends AbstractEffectInfo
   {
      
      public function Effect_156()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，使得对手所有能力增强效果失效";
      }
   }
}

