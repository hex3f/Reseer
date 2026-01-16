package com.robot.core.info.skillEffectInfo
{
   public class Effect_68 extends AbstractEffectInfo
   {
      
      public function Effect_68()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "1回合内，自身受到致死攻击时强制保留1点体力";
      }
   }
}

