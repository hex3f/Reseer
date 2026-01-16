package com.robot.core.info.skillEffectInfo
{
   public class Effect_185 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","疲惫","睡眠"];
      
      public function Effect_185()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若击败" + this.arr[param1[0]] + "的对手，则下一个出场的对手也进入" + this.arr[param1[0]] + "状态";
      }
   }
}

