package com.robot.core.info.skillEffectInfo
{
   public class Effect_171 extends AbstractEffectInfo
   {
      
      public function Effect_171()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return param1[0] + "回合内，自身使用属性技能时能较快出手";
      }
   }
}

