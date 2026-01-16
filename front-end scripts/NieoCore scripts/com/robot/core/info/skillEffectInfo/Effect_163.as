package com.robot.core.info.skillEffectInfo
{
   public class Effect_163 extends AbstractEffectInfo
   {
      
      public function Effect_163()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手使用属性技能则对手随机进入烧伤、冻伤、中毒、麻痹、害怕、睡眠中的一种异常状态";
      }
   }
}

