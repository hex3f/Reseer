package com.robot.core.info.skillEffectInfo
{
   public class Effect_193 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","疲惫","睡眠"];
      
      public function Effect_193()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手" + this.arr[param1[0]] + "，则必定致命一击";
      }
   }
}

