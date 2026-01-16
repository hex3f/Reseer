package org.taomee.utils
{
   import flash.utils.ByteArray;
   
   public class StringUtil
   {
      
      private static const HEX_Head:String = "0x";
      
      public function StringUtil()
      {
         super();
      }
      
      public static function trim(param1:String) : String
      {
         return StringUtil.leftTrim(StringUtil.rightTrim(param1));
      }
      
      public static function ipToUint(param1:String) : uint
      {
         var str:String = null;
         var i:String = param1;
         str = null;
         var arr:Array = i.split(".");
         str = HEX_Head;
         arr.forEach(function(param1:String, param2:int, param3:Array):void
         {
            str += uint(param1).toString(16);
         });
         return uint(str);
      }
      
      public static function timeFormat(param1:int, param2:String = "-") : String
      {
         var _loc3_:Date = new Date(param1 * 1000);
         return _loc3_.getFullYear().toString() + param2 + (_loc3_.getMonth() + 1).toString() + param2 + _loc3_.getDate().toString();
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(param1.length - param2.length);
      }
      
      public static function remove(param1:String, param2:String) : String
      {
         return StringUtil.replace(param1,param2,"");
      }
      
      public static function leftTrim(param1:String) : String
      {
         var _loc2_:Number = param1.length;
         var _loc3_:Number = 0;
         while(_loc3_ < _loc2_)
         {
            if(param1.charCodeAt(_loc3_) > 32)
            {
               return param1.substring(_loc3_);
            }
            _loc3_++;
         }
         return "";
      }
      
      public static function stopwatchFormat(param1:int) : String
      {
         var _loc2_:int = param1 / 60;
         var _loc3_:int = param1 % 60;
         var _loc4_:String = _loc2_ < 10 ? "0" + _loc2_.toString() : _loc2_.toString();
         var _loc5_:String = _loc3_ < 10 ? "0" + _loc3_.toString() : _loc3_.toString();
         return _loc4_ + ":" + _loc5_;
      }
      
      public static function stringHasValue(param1:String) : Boolean
      {
         return param1 != null && param1.length > 0;
      }
      
      public static function beginsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(0,param2.length);
      }
      
      public static function replace(param1:String, param2:String, param3:String) : String
      {
         var _loc4_:Number = NaN;
         var _loc5_:String = new String();
         var _loc6_:Boolean = false;
         var _loc7_:Number = param1.length;
         var _loc8_:Number = param2.length;
         var _loc9_:Number = 0;
         for(; _loc9_ < _loc7_; _loc9_++)
         {
            if(param1.charAt(_loc9_) == param2.charAt(0))
            {
               _loc6_ = true;
               _loc4_ = 0;
               while(_loc4_ < _loc8_)
               {
                  if(param1.charAt(_loc9_ + _loc4_) != param2.charAt(_loc4_))
                  {
                     _loc6_ = false;
                     break;
                  }
                  _loc4_++;
               }
               if(_loc6_)
               {
                  _loc5_ += param3;
                  _loc9_ += _loc8_ - 1;
                  continue;
               }
            }
            _loc5_ += param1.charAt(_loc9_);
         }
         return _loc5_;
      }
      
      public static function renewZero(param1:String, param2:int) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = "";
         var _loc5_:int = param1.length;
         if(_loc5_ < param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param2 - _loc5_)
            {
               _loc4_ += "0";
               _loc3_++;
            }
            return _loc4_ + param1;
         }
         return param1;
      }
      
      public static function toByteArray(param1:String, param2:uint) : ByteArray
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param1);
         _loc3_.length = param2;
         _loc3_.position = 0;
         return _loc3_;
      }
      
      public static function stringsAreEqual(param1:String, param2:String, param3:Boolean) : Boolean
      {
         if(param3)
         {
            return param1 == param2;
         }
         return param1.toUpperCase() == param2.toUpperCase();
      }
      
      public static function uintToIp(param1:uint) : String
      {
         var _loc2_:String = param1.toString(16);
         var _loc3_:String = uint(HEX_Head + _loc2_.slice(0,2)).toString();
         var _loc4_:String = uint(HEX_Head + _loc2_.slice(2,4)).toString();
         var _loc5_:String = uint(HEX_Head + _loc2_.slice(4,6)).toString();
         var _loc6_:String = uint(HEX_Head + _loc2_.slice(6)).toString();
         return _loc3_ + "." + _loc4_ + "." + _loc5_ + "." + _loc6_;
      }
      
      public static function hexToIp(param1:uint) : String
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(param1);
         _loc2_.position = 0;
         var _loc3_:String = "";
         var _loc4_:Number = 0;
         while(_loc4_ < 4)
         {
            _loc3_ += _loc2_.readUnsignedByte().toString() + ".";
            _loc4_++;
         }
         return _loc3_.substr(0,_loc3_.length - 1);
      }
      
      public static function rightTrim(param1:String) : String
      {
         var _loc2_:Number = param1.length;
         var _loc3_:Number = _loc2_;
         while(_loc3_ > 0)
         {
            if(param1.charCodeAt(_loc3_ - 1) > 32)
            {
               return param1.substring(0,_loc3_);
            }
            _loc3_--;
         }
         return "";
      }
   }
}

