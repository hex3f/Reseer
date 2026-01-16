package com.robot.core.info.skillEffectInfo
{
   public class Effect_43 extends AbstractEffectInfo
   {
      
      public function Effect_43()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "回复相当于自身[最大体力]1/" + param1[0] + "的HP";
      }
   }
}

