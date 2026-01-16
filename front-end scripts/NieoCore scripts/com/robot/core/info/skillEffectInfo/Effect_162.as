package com.robot.core.info.skillEffectInfo
{
   public class Effect_162 extends AbstractEffectInfo
   {
      
      public function Effect_162()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于异常状态，则附加" + param1[0] + "点伤害";
      }
   }
}

