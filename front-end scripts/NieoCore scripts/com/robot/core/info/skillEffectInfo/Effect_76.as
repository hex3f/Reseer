package com.robot.core.info.skillEffectInfo
{
   public class Effect_76 extends AbstractEffectInfo
   {
      
      public function Effect_76()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率令对手在" + param1[1] + "回合内，每回合受到" + param1[2] + "点固定伤害";
      }
   }
}

