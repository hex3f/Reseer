package com.robot.core.info.skillEffectInfo
{
   public class Effect_83 extends AbstractEffectInfo
   {
      
      public function Effect_83()
      {
         super();
         _argsNum = 0;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return " 自身雄性，下两回合必定先手；自身雌性，下两回合必定致命一击";
      }
   }
}

