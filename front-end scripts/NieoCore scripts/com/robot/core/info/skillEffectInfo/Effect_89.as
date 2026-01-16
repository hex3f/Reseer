package com.robot.core.info.skillEffectInfo
{
   public class Effect_89 extends AbstractEffectInfo
   {
      
      public function Effect_89()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，每次造成伤害的1/" + param1[1] + "会恢复自己的HP";
      }
   }
}

