package com.robot.core.info.skillEffectInfo
{
   public class Effect_78 extends AbstractEffectInfo
   {
      
      public function Effect_78()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，物理攻击对自身必定miss";
      }
   }
}

