package com.robot.core.info.skillEffectInfo
{
   public class Effect_176 extends AbstractEffectInfo
   {
      
      public function Effect_176()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率令对手随机进入烧伤、冻伤、中毒、麻痹、害怕、睡眠中的一种异常状态";
      }
   }
}

