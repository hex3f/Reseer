package com.robot.core.info.skillEffectInfo
{
   public class Effect_187 extends AbstractEffectInfo
   {
      
      public function Effect_187()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，若对手使用属性技能，则自身恢复1/" + param1[1] + "最大体力值";
      }
   }
}

