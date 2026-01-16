package com.robot.core.info.skillEffectInfo
{
   public class Effect_98 extends AbstractEffectInfo
   {
      
      public function Effect_98()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:uint = uint(param1[0]);
         var _loc3_:uint = uint(param1[1]);
         return String(_loc2_ + "回合内，对雄性精灵的伤害为" + _loc3_ + "倍");
      }
   }
}

