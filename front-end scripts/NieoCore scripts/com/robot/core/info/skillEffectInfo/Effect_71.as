package com.robot.core.info.skillEffectInfo
{
   public class Effect_71 extends AbstractEffectInfo
   {
      
      public function Effect_71()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "自己牺牲(体力降到0), 使下一只出战精灵在前两回合内必定致命一击";
      }
   }
}

