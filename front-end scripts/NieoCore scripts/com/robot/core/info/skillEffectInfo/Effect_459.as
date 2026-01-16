package com.robot.core.info.skillEffectInfo
{
   public class Effect_459 extends AbstractEffectInfo
   {
      
      public function Effect_459()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加对手防御值" + param1[0] + "%的固定伤害";
      }
   }
}

