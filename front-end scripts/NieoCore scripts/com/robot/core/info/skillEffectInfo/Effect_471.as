package com.robot.core.info.skillEffectInfo
{
   public class Effect_471 extends AbstractEffectInfo
   {
      
      public function Effect_471()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "先出手时" + param1[0] + "回合内免疫异常状态";
      }
   }
}

