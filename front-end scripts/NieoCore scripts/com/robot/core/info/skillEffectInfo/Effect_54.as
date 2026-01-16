package com.robot.core.info.skillEffectInfo
{
   public class Effect_54 extends AbstractEffectInfo
   {
      
      public function Effect_54()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(param1[1] == 2)
         {
            return param1[0] + "回合内，令对方的攻击伤害变为50%";
         }
         if(param1[1] == 4)
         {
            return param1[0] + "回合内，令对方的攻击伤害变为25%";
         }
         if(param1[1] == 5)
         {
            return param1[0] + "回合内，令对方的攻击伤害变为20%";
         }
         return param1[0] + "回合内，令对方的攻击伤害变为1/" + param1[1];
      }
   }
}

