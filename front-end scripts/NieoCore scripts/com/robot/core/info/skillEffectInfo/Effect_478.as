package com.robot.core.info.skillEffectInfo
{
   public class Effect_478 extends AbstractEffectInfo
   {
      
      public function Effect_478()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内对手使用的属性技能无效果 ";
      }
   }
}

