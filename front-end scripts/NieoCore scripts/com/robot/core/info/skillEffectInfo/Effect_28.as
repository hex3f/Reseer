package com.robot.core.info.skillEffectInfo
{
   public class Effect_28 extends AbstractEffectInfo
   {
      
      public function Effect_28()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "削减对方1/" + param1[0] + "的HP";
      }
   }
}

