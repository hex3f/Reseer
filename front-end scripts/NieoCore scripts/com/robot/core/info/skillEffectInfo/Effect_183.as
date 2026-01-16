package com.robot.core.info.skillEffectInfo
{
   public class Effect_183 extends AbstractEffectInfo
   {
      
      private var arr:Array = ["","物理伤害","特殊伤害"];
      
      public function Effect_183()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内免疫并反弹" + this.arr[param1[1]];
      }
   }
}

