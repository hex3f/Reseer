package org.taomee.utils
{
   public class MathUtil
   {
      
      public function MathUtil()
      {
         super();
      }
      
      public static function randomHalfAdd(param1:Number) : Number
      {
         return param1 + Math.random() * (param1 / 2);
      }
      
      public static function randomHalve(param1:Number) : Number
      {
         return param1 - Math.random() * (param1 / 2);
      }
      
      public static function randomRegion(param1:Number, param2:Number) : Number
      {
         return param1 + Math.random() * (param2 - param1);
      }
   }
}

