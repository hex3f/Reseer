package com.robot.core.info.skillEffectInfo
{
   public class Effect_455 extends AbstractEffectInfo
   {
      
      public function Effect_455()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "每损失" + param1[0] + "点体力则额外附加" + param1[1] + "点固定伤害";
      }
   }
}

