package com.robot.core.info.skillEffectInfo
{
   public class Effect_403 extends AbstractEffectInfo
   {
      
      public function Effect_403()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "技能使用成功时，" + param1[0] + "%令自身特攻和速度等级+" + param1[1] + "。若和对手属性相同，则技能效果翻倍";
      }
   }
}

