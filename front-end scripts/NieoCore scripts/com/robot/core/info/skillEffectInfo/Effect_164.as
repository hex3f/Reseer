package com.robot.core.info.skillEffectInfo
{
   public class Effect_164 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠","石化"];
      
      public function Effect_164()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若受到攻击则有" + param1[1] + "%几率令对手" + this.arr[param1[2]];
      }
   }
}

