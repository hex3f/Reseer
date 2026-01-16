package com.robot.core.info.skillEffectInfo
{
   public class Effect_175 extends AbstractEffectInfo
   {
      
      public function Effect_175()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:* = "若对手处于异常状态，则" + param1[1] + "%自身" + propDict[param1[0]] + "等级";
         if(param1[2] > 0)
         {
            return _loc2_ + "+" + param1[2];
         }
         return _loc2_ + param1[2];
      }
   }
}

