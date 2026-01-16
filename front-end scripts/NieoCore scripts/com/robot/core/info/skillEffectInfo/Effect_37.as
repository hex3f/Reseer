package com.robot.core.info.skillEffectInfo
{
   public class Effect_37 extends AbstractEffectInfo
   {
      
      public function Effect_37()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(Boolean(param1[1] % 1))
         {
            return "自身的HP小于1/" + param1[0] + "的场合，该技能[威力]增加" + (param1[1] - 1) * 100 + "%";
         }
         return "自身的HP小于1/" + param1[0] + "的场合，该技能[威力]增加" + (param1[1] - 1) + "00%";
      }
   }
}

