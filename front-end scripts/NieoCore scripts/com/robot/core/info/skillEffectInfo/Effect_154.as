package com.robot.core.info.skillEffectInfo
{
   public class Effect_154 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_154()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手" + this.arr[param1[0]] + "，则对对方造成伤害的1/" + param1[1] + "恢复自身体力";
      }
   }
}

