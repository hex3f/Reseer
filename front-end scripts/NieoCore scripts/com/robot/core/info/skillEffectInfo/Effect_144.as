package com.robot.core.info.skillEffectInfo
{
   public class Effect_144 extends AbstractEffectInfo
   {
      
      public function Effect_144()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "消耗自己所有体力，使下一个出战的精灵" + param1[0] + "回合免疫异常状态";
      }
   }
}

