package com.robot.core.info.skillEffectInfo
{
   public class Effect_103 extends AbstractEffectInfo
   {
      
      public function Effect_103()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "%几率令对手增加一层衰弱";
      }
   }
}

