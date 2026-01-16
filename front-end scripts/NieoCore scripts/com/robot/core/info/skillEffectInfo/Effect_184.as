package com.robot.core.info.skillEffectInfo
{
   public class Effect_184 extends AbstractEffectInfo
   {
      
      public function Effect_184()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "若对手处于能力提升状态，则" + param1[1] + "%自身" + propDict[param1[0]] + "等级+" + param1[2];
      }
   }
}

