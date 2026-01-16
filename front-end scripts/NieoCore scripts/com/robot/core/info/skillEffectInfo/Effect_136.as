package com.robot.core.info.skillEffectInfo
{
   public class Effect_136 extends AbstractEffectInfo
   {
      
      public function Effect_136()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若Miss则自己恢复1/" + param1[0] + "体力";
      }
   }
}

