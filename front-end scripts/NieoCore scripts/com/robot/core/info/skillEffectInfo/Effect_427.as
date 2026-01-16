package com.robot.core.info.skillEffectInfo
{
   public class Effect_427 extends AbstractEffectInfo
   {
      
      public function Effect_427()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内每次直接攻击都会使对手防御和特防" + param1[1];
      }
   }
}

