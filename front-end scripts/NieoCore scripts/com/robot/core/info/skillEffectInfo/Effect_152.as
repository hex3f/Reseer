package com.robot.core.info.skillEffectInfo
{
   public class Effect_152 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["麻痹","中毒","烧伤","","","冻伤","害怕","","睡眠"];
      
      public function Effect_152()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对方使用属性技能，则" + param1[1] + "%使对方" + this.arr[param1[2]];
      }
   }
}

