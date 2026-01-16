package com.robot.core.info.skillEffectInfo
{
   public class Effect_174 extends AbstractEffectInfo
   {
      
      public function Effect_174()
      {
         super();
         _argsNum = 5;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = null;
         if(param1[2] == -1)
         {
            _loc2_ = param1[0] + "回合内，若对手使用属性攻击则" + param1[3] + "%自身" + propDict[param1[1]] + "等级+" + param1[4];
         }
         else
         {
            _loc2_ = param1[0] + "回合内，若对手使用属性攻击则" + param1[3] + "%自身" + propDict[param1[1]] + "和" + propDict[param1[2]] + "等级+" + param1[4];
         }
         return _loc2_;
      }
   }
}

