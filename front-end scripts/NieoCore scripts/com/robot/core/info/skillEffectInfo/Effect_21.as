package com.robot.core.info.skillEffectInfo
{
   public class Effect_21 extends AbstractEffectInfo
   {
      
      public function Effect_21()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = null;
         if(param1[0] != param1[1])
         {
            _loc2_ = param1[0] + "~" + param1[1] + "回合内，将自身所受伤害的1/" + param1[2] + "反弹给对方";
         }
         else
         {
            _loc2_ = param1[0] + "回合内，将自身所受伤害的1/" + param1[2] + "反弹给对方";
         }
         return _loc2_;
      }
   }
}

