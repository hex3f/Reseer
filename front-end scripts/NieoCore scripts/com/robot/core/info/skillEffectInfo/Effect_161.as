package com.robot.core.info.skillEffectInfo
{
   public class Effect_161 extends AbstractEffectInfo
   {
      
      public function Effect_161()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%降低自身当前体力值的1/" + param1[1];
      }
   }
}

