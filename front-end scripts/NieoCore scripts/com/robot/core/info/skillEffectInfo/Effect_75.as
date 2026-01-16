package com.robot.core.info.skillEffectInfo
{
   public class Effect_75 extends AbstractEffectInfo
   {
      
      public function Effect_75()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "命中时有30%几率令对手麻痹、睡眠或害怕";
      }
   }
}

