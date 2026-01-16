package com.robot.core.info.skillEffectInfo
{
   public class Effect_147 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_147()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "后出手时，" + param1[0] + "%概率使对方" + this.arr[param1[1]];
      }
   }
}

