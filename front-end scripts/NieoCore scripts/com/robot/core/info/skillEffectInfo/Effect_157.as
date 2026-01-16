package com.robot.core.info.skillEffectInfo
{
   public class Effect_157 extends AbstractEffectInfo
   {
      
      public function Effect_157()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若受到攻击，对手防御等级-1、特防等级-1、命中等级-1";
      }
   }
}

