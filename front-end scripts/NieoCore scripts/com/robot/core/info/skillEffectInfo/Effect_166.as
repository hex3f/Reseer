package com.robot.core.info.skillEffectInfo
{
   public class Effect_166 extends AbstractEffectInfo
   {
      
      public function Effect_166()
      {
         super();
         _argsNum = 4;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手使用属性攻击则" + param1[2] + "%对手" + propDict[param1[1]] + "等级" + param1[3];
      }
   }
}

