package com.robot.core.info.skillEffectInfo
{
   public class Effect_121 extends AbstractEffectInfo
   {
      
      public function Effect_121()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "属性相同时，" + param1[0] + "%几率让对方麻痹";
      }
   }
}

