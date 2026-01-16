package com.robot.core.info.skillEffectInfo
{
   public class Effect_422 extends AbstractEffectInfo
   {
      
      public function Effect_422()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加所造成伤害值" + param1[0] + "%的固定伤害";
      }
   }
}

