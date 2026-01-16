package com.robot.core.info.skillEffectInfo
{
   public class Effect_31 extends AbstractEffectInfo
   {
      
      public function Effect_31()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = null;
         if(param1[0] != param1[1])
         {
            _loc2_ = "连续进行" + param1[0] + "~" + param1[1] + "次攻击";
         }
         else
         {
            _loc2_ = "连续进行" + param1[0] + "次攻击";
         }
         return _loc2_;
      }
   }
}

