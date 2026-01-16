package com.robot.core.info.skillEffectInfo
{
   public class Effect_149 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_149()
      {
         super();
         _argsNum = 4;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中后，" + param1[0] + "%令对方" + this.arr[param1[1]] + "，" + param1[2] + "%令对方" + this.arr[param1[3]];
      }
   }
}

