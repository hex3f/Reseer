package com.robot.core.info.skillEffectInfo
{
   public class Effect_1635 extends AbstractEffectInfo
   {
      
      public function Effect_1635()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "立刻恢复自身" + param1[0] + "点体力，" + param1[1] + "回合后恢复自身全部体力";
      }
   }
}

