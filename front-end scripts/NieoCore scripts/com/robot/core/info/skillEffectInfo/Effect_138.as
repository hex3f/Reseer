package com.robot.core.info.skillEffectInfo
{
   public class Effect_138 extends AbstractEffectInfo
   {
      
      public function Effect_138()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "先出手时，" + param1[0] + "回合自己不会受到对手攻击性技能伤害并反弹对手造成伤害的1/" + param1[1];
      }
   }
}

