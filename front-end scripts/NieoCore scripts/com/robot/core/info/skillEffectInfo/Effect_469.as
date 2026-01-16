package com.robot.core.info.skillEffectInfo
{
   public class Effect_469 extends AbstractEffectInfo
   {
      
      public function Effect_469()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内若对手使用属性技能则" + param1[1] + "%几率令对手" + statusDict[param1[2]];
      }
   }
}

