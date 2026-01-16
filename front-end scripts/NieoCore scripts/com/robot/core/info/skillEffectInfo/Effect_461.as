package com.robot.core.info.skillEffectInfo
{
   public class Effect_461 extends AbstractEffectInfo
   {
      
      public function Effect_461()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若自身生命值低于1/" + param1[0] + "则从下回合开始必定致命一击";
      }
   }
}

