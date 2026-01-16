package com.robot.core.info.skillEffectInfo
{
   public class Effect_178 extends AbstractEffectInfo
   {
      
      public function Effect_178()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "造成伤害的1/" + param1[0] + "回复自身体力，若属性相同则造成伤害的1/" + param1[1] + "回复自身体力";
      }
   }
}

