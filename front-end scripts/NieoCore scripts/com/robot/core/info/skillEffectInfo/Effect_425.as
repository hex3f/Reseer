package com.robot.core.info.skillEffectInfo
{
   public class Effect_425 extends AbstractEffectInfo
   {
      
      public function Effect_425()
      {
         super();
         _argsNum = 2;
      }
      
      override public function getInfo(param1:Array = null) : String
      {
         return "随机吸取对手" + param1[0] + "项属性" + param1[1] + "，并将该属性附加给自己";
      }
   }
}

