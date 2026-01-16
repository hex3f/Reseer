package com.robot.core.info.skillEffectInfo
{
   public class Effect_451 extends AbstractEffectInfo
   {
      
      public function Effect_451()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中后" + param1[0] + "%随机令对手进入烧伤，冻伤，中毒中的一种";
      }
   }
}

