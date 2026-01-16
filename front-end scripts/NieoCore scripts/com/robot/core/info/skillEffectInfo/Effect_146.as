package com.robot.core.info.skillEffectInfo
{
   public class Effect_146 extends AbstractEffectInfo
   {
      
      public function Effect_146()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，受到物理攻击时有" + param1[1] + "%几率使对方中毒";
      }
   }
}

