package com.robot.app.bag
{
   public class BagShowType
   {
      
      public static const ALL:int = 0;
      
      public static const SUIT:int = 1;
      
      public static const ELITE_SUIT:int = 2;
      
      public static const FLAG_HEAD:int = 3;
      
      public static const FLAG_EYE:int = 4;
      
      public static const FLAG_HAND:int = 5;
      
      public static const FLAG_WAIST:int = 6;
      
      public static const FLAG_FOOT:int = 7;
      
      public static var currType:int = ALL;
      
      public static var currSuitID:uint = 0;
      
      public static var typeNameList:Array = ["全部","套装","精品套装","头部","脸部","手部","腰带","脚部"];
      
      public static var typeNameListEn:Array = ["all","suit","eliteSuit","head","eye","hand","waist","foot"];
      
      public function BagShowType()
      {
         super();
      }
   }
}

