package com.robot.core.info.skillEffectInfo
{
   public class Effect_105 extends AbstractEffectInfo
   {
      
      public function Effect_105()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "给予对象损伤的1/" + param1[0] + "，会回复自己的HP";
      }
   }
}

