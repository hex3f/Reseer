package com.robot.core.info.skillEffectInfo
{
   public class Effect_107 extends AbstractEffectInfo
   {
      
      public function Effect_107()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         var _loc2_:String = "";
         switch(param1[1])
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
         return "若本次攻击造成的伤害小于" + param1[0] + "，则自身" + _loc2_ + "提升1个等级";
      }
   }
}

