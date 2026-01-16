package com.robot.core.info.skillEffectInfo
{
   public class Effect_418 extends AbstractEffectInfo
   {
      
      public function Effect_418()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         if(param1[1] > 0)
         {
            return "若对手处于能力提升状态则对方" + propDict[param1[0]] + "等级+" + param1[1];
         }
         return "若对手处于能力提升状态则对方" + propDict[param1[0]] + "等级" + param1[1];
      }
   }
}

