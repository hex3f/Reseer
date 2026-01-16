package com.robot.core.info.skillEffectInfo
{
   public class Effect_42 extends AbstractEffectInfo
   {
      
      public function Effect_42()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = null;
         if(param1[0] != param1[1])
         {
            _loc2_ = param1[0] + "~" + param1[1] + "回合内，自身的电招式伤害提升100%";
         }
         else
         {
            _loc2_ = param1[0] + "回合内，自身的电招式伤害提升100%";
         }
         return _loc2_;
      }
   }
}

