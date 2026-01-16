package com.robot.core.info.skillEffectInfo
{
   public class Effect_86 extends AbstractEffectInfo
   {
      
      public function Effect_86()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，属性攻击对自身必定miss";
      }
   }
}

