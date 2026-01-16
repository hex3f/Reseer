package com.robot.core.info.skillEffectInfo
{
   public class Effect_159 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_159()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "自身体力小于最大值的1/" + param1[0] + "时，" + param1[1] + "%几率令对方" + this.arr[param1[2]];
      }
   }
}

