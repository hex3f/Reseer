package com.robot.core.info.skillEffectInfo
{
   public class Effect_177 extends AbstractEffectInfo
   {
      
      public function Effect_177()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手MISS则自身恢复1/" + param1[1] + "的最大体力值";
      }
   }
}

