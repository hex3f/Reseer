package com.robot.core.info.skillEffectInfo
{
   public class Effect_95 extends AbstractEffectInfo
   {
      
      public function Effect_95()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:Number = param1[0] / 16;
         _loc2_ = Number(_loc2_.toFixed(2)) * 100;
         return "对手处于睡眠状态时，致命一击率提升" + _loc2_ + "%";
      }
   }
}

