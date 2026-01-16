package com.robot.core.info.skillEffectInfo
{
   public class Effect_450 extends AbstractEffectInfo
   {
      
      public function Effect_450()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "随机恢复" + param1[0] + "到" + param1[1] + "点生命值";
      }
   }
}

