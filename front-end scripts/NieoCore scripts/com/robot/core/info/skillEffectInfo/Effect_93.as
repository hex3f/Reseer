package com.robot.core.info.skillEffectInfo
{
   public class Effect_93 extends AbstractEffectInfo
   {
      
      public function Effect_93()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率额外附加" + param1[1] + "点固定伤害";
      }
   }
}

