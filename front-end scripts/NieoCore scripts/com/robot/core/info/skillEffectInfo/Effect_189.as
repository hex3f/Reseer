package com.robot.core.info.skillEffectInfo
{
   public class Effect_189 extends AbstractEffectInfo
   {
      
      public function Effect_189()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若受到攻击，对手攻击等级-1、特攻等级-1";
      }
   }
}

