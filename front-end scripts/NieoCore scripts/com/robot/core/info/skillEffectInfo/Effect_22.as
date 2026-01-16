package com.robot.core.info.skillEffectInfo
{
   public class Effect_22 extends AbstractEffectInfo
   {
      
      public function Effect_22()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率令对方陷入疲惫状态，" + param1[1] + "回合无法行动";
      }
   }
}

