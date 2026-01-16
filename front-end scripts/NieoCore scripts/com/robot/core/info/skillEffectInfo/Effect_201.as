package com.robot.core.info.skillEffectInfo
{
   public class Effect_201 extends AbstractEffectInfo
   {
      
      public function Effect_201()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对选中对象或本方全体恢复1/" + param1[1] + "的体力";
      }
   }
}

