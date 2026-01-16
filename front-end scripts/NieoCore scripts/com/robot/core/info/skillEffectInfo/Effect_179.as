package com.robot.core.info.skillEffectInfo
{
   public class Effect_179 extends AbstractEffectInfo
   {
      
      public function Effect_179()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若属性相同则技能威力提升" + param1[0];
      }
   }
}

