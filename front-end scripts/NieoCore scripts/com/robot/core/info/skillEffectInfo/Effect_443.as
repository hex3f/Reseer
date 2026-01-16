package com.robot.core.info.skillEffectInfo
{
   public class Effect_443 extends AbstractEffectInfo
   {
      
      public function Effect_443()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内若受到的伤害超过" + param1[1] + "则对手疲惫" + param1[2] + "回合";
      }
   }
}

