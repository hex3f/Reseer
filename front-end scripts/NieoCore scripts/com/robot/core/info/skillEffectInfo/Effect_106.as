package com.robot.core.info.skillEffectInfo
{
   public class Effect_106 extends AbstractEffectInfo
   {
      
      public function Effect_106()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，特殊攻击对自身必定miss";
      }
   }
}

