package com.robot.core.info.skillEffectInfo
{
   public class Effect_69 extends AbstractEffectInfo
   {
      
      public function Effect_69()
      {
         super();
         _argsNum = 5;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return _argsNum + "回合内，对方使用体力药剂的效果变成削减体力";
      }
   }
}

