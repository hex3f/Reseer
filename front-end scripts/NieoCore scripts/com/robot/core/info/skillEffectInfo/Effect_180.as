package com.robot.core.info.skillEffectInfo
{
   public class Effect_180 extends AbstractEffectInfo
   {
      
      public function Effect_180()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "令对手当前拥有的回合类效果失效";
      }
   }
}

