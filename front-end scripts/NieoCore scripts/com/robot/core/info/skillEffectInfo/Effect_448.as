package com.robot.core.info.skillEffectInfo
{
   public class Effect_448 extends AbstractEffectInfo
   {
      
      public function Effect_448()
      {
         super();
         _argsNum = 7;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:int = 0;
         var _loc3_:Array = [null,"攻击等级","防御等级","特攻等级","特防等级","速度等级","命中等级"];
         var _loc4_:Array = [];
         var _loc5_:String = "";
         _loc2_ = 1;
         while(_loc2_ < 7)
         {
            if(param1[_loc2_] < 0)
            {
               _loc4_.push([_loc3_[_loc2_],param1[_loc2_]]);
            }
            _loc2_++;
         }
         var _loc6_:* = "";
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            _loc6_ += _loc4_[_loc2_][0];
            _loc6_ += _loc4_[_loc2_][1];
            if(_loc2_ != _loc4_.length - 1)
            {
               _loc6_ += "，";
            }
            _loc2_++;
         }
         return param1[0] + "回合内，每回合对手" + _loc6_;
      }
   }
}

