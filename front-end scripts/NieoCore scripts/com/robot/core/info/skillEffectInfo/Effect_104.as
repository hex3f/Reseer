package com.robot.core.info.skillEffectInfo
{
   public class Effect_104 extends AbstractEffectInfo
   {
      
      public function Effect_104()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每次直接攻击都有" + param1[1] + "%几率附带衰弱效果";
      }
   }
}

