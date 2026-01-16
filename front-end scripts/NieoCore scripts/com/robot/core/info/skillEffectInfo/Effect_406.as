package com.robot.core.info.skillEffectInfo
{
   public class Effect_406 extends AbstractEffectInfo
   {
      
      public function Effect_406()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内受到攻击" + param1[1] + "%几率回复" + param1[2] + "点体力";
      }
   }
}

