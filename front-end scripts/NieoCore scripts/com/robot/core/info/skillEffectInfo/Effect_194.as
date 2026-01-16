package com.robot.core.info.skillEffectInfo
{
   public class Effect_194 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","疲惫","睡眠"];
      
      public function Effect_194()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "造成伤害的1/" + param1[0] + "回复自身体力，若对手" + this.arr[param1[1]] + "，则造成伤害的1/" + param1[2] + "回复自身体力";
      }
   }
}

