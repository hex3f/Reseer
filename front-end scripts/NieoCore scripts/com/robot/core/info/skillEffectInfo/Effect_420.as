package com.robot.core.info.skillEffectInfo
{
   public class Effect_420 extends AbstractEffectInfo
   {
      
      public function Effect_420()
      {
         super();
         _argsNum = 1;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(param1[0] > 0)
         {
            return "使用了该技能后，若受到消除强化类技能攻击，则对方攻击和特攻等级+" + param1[0];
         }
         return "使用了该技能后，若受到消除强化类技能攻击，则对方攻击和特攻等级" + param1[0];
      }
   }
}

