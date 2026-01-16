package com.robot.core.info.skillEffectInfo
{
   public class Effect_482 extends AbstractEffectInfo
   {
      
      public function Effect_482()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率先制+" + param1[1];
      }
   }
}

