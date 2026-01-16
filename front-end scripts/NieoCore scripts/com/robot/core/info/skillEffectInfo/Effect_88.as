package com.robot.core.info.skillEffectInfo
{
   public class Effect_88 extends AbstractEffectInfo
   {
      
      public function Effect_88()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率伤害为" + param1[1] + "倍";
      }
   }
}

