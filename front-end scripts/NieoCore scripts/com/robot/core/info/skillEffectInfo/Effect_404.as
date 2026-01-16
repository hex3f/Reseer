package com.robot.core.info.skillEffectInfo
{
   public class Effect_404 extends AbstractEffectInfo
   {
      
      public function Effect_404()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "恢复双方所有体力";
      }
   }
}

