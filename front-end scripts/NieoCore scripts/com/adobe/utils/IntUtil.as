package com.adobe.utils
{
   public class IntUtil
   {
      
      private static var hexChars:String = "0123456789abcdef";
      
      public function IntUtil()
      {
         super();
      }
      
      public static function toHex(param1:int, param2:Boolean = false) : String
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = "";
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc5_ += hexChars.charAt(param1 >> (3 - _loc3_) * 8 + 4 & 0x0F) + hexChars.charAt(param1 >> (3 - _loc3_) * 8 & 0x0F);
               _loc3_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               _loc5_ += hexChars.charAt(param1 >> _loc4_ * 8 + 4 & 0x0F) + hexChars.charAt(param1 >> _loc4_ * 8 & 0x0F);
               _loc4_++;
            }
         }
         return _loc5_;
      }
      
      public static function ror(param1:int, param2:int) : uint
      {
         var _loc3_:int = 32 - param2;
         return param1 << _loc3_ | param1 >>> 32 - _loc3_;
      }
      
      public static function rol(param1:int, param2:int) : int
      {
         return param1 << param2 | param1 >>> 32 - param2;
      }
   }
}

