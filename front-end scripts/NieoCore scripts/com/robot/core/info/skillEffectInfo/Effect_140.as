package com.robot.core.info.skillEffectInfo
{
   public class Effect_140 extends AbstractEffectInfo
   {
      
      public function Effect_140()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "随机降低对手1/" + param1[0] + "至1/" + param1[1] + "的当前体力值";
      }
   }
}

