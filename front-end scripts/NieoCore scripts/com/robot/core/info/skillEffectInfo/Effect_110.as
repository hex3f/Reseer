package com.robot.core.info.skillEffectInfo
{
   public class Effect_110 extends AbstractEffectInfo
   {
      
      public function Effect_110()
      {
         super();
         _argsNum = 3;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = "";
         switch(param1[2])
         {
            case "0":
               _loc2_ = "攻击";
               break;
            case "1":
               _loc2_ = "防御";
               break;
            case "2":
               _loc2_ = "特攻";
               break;
            case "3":
               _loc2_ = "特防";
               break;
            case "4":
               _loc2_ = "速度";
               break;
            case "5":
               _loc2_ = "命中";
         }
         return param1[0] + "回合内，每次躲避攻击都有" + param1[1] + "%几率使自身" + _loc2_ + "提升1个等级";
      }
   }
}

