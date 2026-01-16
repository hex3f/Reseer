package com.robot.core.info.skillEffectInfo
{
   public class Effect_434 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_434()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若自身处于能力强化状态，则" + param1[0] + "%几率令对手" + this.arr[param1[1]];
      }
   }
}

