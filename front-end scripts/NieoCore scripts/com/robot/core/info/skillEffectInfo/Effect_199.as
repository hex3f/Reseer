package com.robot.core.info.skillEffectInfo
{
   public class Effect_199 extends AbstractEffectInfo
   {
      
      public function Effect_199()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "被击败后，下一个出场的精灵" + propDict[param1[0]] + "等级+" + param1[1];
      }
   }
}

