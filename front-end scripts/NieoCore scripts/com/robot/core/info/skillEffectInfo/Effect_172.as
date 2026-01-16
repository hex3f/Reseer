package com.robot.core.info.skillEffectInfo
{
   public class Effect_172 extends AbstractEffectInfo
   {
      
      public function Effect_172()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若后出手，则给予对方损伤的1/" + param1[0] + "会回复自己的体力";
      }
   }
}

