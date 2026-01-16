package com.robot.core.info.skillEffectInfo
{
   public class Effect_56 extends AbstractEffectInfo
   {
      
      public function Effect_56()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，复制对方的属性";
      }
   }
}

