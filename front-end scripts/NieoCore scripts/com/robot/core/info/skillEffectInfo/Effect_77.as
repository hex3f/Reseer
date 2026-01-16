package com.robot.core.info.skillEffectInfo
{
   public class Effect_77 extends AbstractEffectInfo
   {
      
      public function Effect_77()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每回合恢复" + param1[1] + "点固定体力值";
      }
   }
}

