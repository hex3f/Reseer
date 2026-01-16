package org.taomee.utils
{
   import flash.utils.ByteArray;
   
   public class Base64
   {
      
      private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
      
      public static const version:String = "1.0.0";
      
      public function Base64()
      {
         super();
         throw new Error("Base64 class is static container only");
      }
      
      public static function encode(param1:String) : String
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return encodeByteArray(_loc2_);
      }
      
      public static function encodeByteArray(param1:ByteArray) : String
      {
         var _loc2_:Array = null;
         var _loc3_:Number = 0;
         var _loc4_:* = 0;
         var _loc5_:Number = 0;
         var _loc6_:String = "";
         var _loc7_:Array = new Array(4);
         param1.position = 0;
         while(param1.bytesAvailable > 0)
         {
            _loc2_ = new Array();
            _loc3_ = 0;
            while(_loc3_ < 3 && param1.bytesAvailable > 0)
            {
               _loc2_[_loc3_] = param1.readUnsignedByte();
               _loc3_++;
            }
            _loc7_[0] = (_loc2_[0] & 0xFC) >> 2;
            _loc7_[1] = (_loc2_[0] & 3) << 4 | _loc2_[1] >> 4;
            _loc7_[2] = (_loc2_[1] & 0x0F) << 2 | _loc2_[2] >> 6;
            _loc7_[3] = _loc2_[2] & 0x3F;
            _loc4_ = _loc2_.length;
            while(_loc4_ < 3)
            {
               _loc7_[_loc4_ + 1] = 64;
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc7_.length)
            {
               _loc6_ += BASE64_CHARS.charAt(_loc7_[_loc5_]);
               _loc5_++;
            }
         }
         return _loc6_;
      }
      
      public static function decode(param1:String) : String
      {
         var _loc2_:ByteArray = decodeToByteArray(param1);
         return _loc2_.readUTFBytes(_loc2_.length);
      }
      
      public static function decodeToByteArray(param1:String) : ByteArray
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = 0;
         var _loc4_:ByteArray = new ByteArray();
         var _loc5_:Array = new Array(4);
         var _loc6_:Array = new Array(3);
         var _loc7_:* = 0;
         while(_loc7_ < param1.length)
         {
            _loc2_ = 0;
            while(_loc2_ < 4 && _loc7_ + _loc2_ < param1.length)
            {
               _loc5_[_loc2_] = BASE64_CHARS.indexOf(param1.charAt(_loc7_ + _loc2_));
               _loc2_++;
            }
            _loc6_[0] = (_loc5_[0] << 2) + ((_loc5_[1] & 0x30) >> 4);
            _loc6_[1] = ((_loc5_[1] & 0x0F) << 4) + ((_loc5_[2] & 0x3C) >> 2);
            _loc6_[2] = ((_loc5_[2] & 3) << 6) + _loc5_[3];
            _loc3_ = 0;
            while(_loc3_ < _loc6_.length)
            {
               if(_loc5_[_loc3_ + 1] == 64)
               {
                  break;
               }
               _loc4_.writeByte(_loc6_[_loc3_]);
               _loc3_++;
            }
            _loc7_ += 4;
         }
         _loc4_.position = 0;
         return _loc4_;
      }
   }
}

