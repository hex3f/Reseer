package com.robot.core.info.skillEffectInfo
{
   public class Effect_545 extends AbstractEffectInfo
   {
      
      public function Effect_545()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内若受到伤害高于" + param1[1] + "则对手" + statusDict[param1[2]];
      }
   }
}

