package com.robot.core.info.skillEffectInfo
{
   public class Effect_119 extends AbstractEffectInfo
   {
      
      public function Effect_119()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若伤害为奇数，30%对手疲惫1回合；若为偶数，30%速度+1";
      }
   }
}

