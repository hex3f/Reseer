package com.robot.core.info.skillEffectInfo
{
   public class Effect_111 extends AbstractEffectInfo
   {
      
      public function Effect_111()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "附加额外伤害，自身等级越高，附加的伤害越高";
      }
   }
}

