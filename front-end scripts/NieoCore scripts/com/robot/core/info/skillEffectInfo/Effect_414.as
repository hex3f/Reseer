package com.robot.core.info.skillEffectInfo
{
   public class Effect_414 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","疲惫","睡眠"];
      
      public function Effect_414()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "对手" + propDict[param1[0]] + "等级" + param1[1] + "，若对手处于" + this.arr[param1[2]] + "状态，则弱化效果翻倍";
      }
   }
}

