package com.robot.core.info.skillEffectInfo
{
   public class Effect_182 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","疲惫","睡眠"];
      
      public function Effect_182()
      {
         super();
         _argsNum = 4;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于" + this.arr[param1[0]] + "状态，" + param1[2] + "%自身" + propDict[param1[1]] + "等级+" + param1[3];
      }
   }
}

