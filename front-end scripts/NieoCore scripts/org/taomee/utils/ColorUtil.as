package org.taomee.utils
{
   public class ColorUtil
   {
      
      public static const RGB_MAX:uint = 256;
      
      public static const HUE_MAX:uint = 360;
      
      public static const PCT_MAX:uint = 100;
      
      public function ColorUtil()
      {
         super();
      }
      
      public static function HueToRGB(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         while(param3 < 0)
         {
            param3 += HUE_MAX;
         }
         _loc7_ = int(param3 / 60);
         _loc6_ = (param3 - _loc7_ * 60) / 60;
         _loc7_ %= 6;
         _loc4_ = param1 + (param2 - param1) * _loc6_;
         _loc5_ = param2 - (param2 - param1) * _loc6_;
         switch(_loc7_)
         {
            case 0:
               return {
                  "r":param2,
                  "g":_loc4_,
                  "b":param1
               };
            case 1:
               return {
                  "r":_loc5_,
                  "g":param2,
                  "b":param1
               };
            case 2:
               return {
                  "r":param1,
                  "g":param2,
                  "b":_loc4_
               };
            case 3:
               return {
                  "r":param1,
                  "g":_loc5_,
                  "b":param2
               };
            case 4:
               return {
                  "r":_loc4_,
                  "g":param1,
                  "b":param2
               };
            case 5:
               return {
                  "r":param2,
                  "g":param1,
                  "b":_loc5_
               };
            default:
               return null;
         }
      }
      
      public static function RGBtoHSV(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = 0;
         _loc5_ = Math.max(param1,Math.max(param2,param3));
         _loc4_ = Math.min(param1,Math.min(param2,param3));
         if(_loc5_ == 0)
         {
            return {
               "h":0,
               "s":0,
               "v":0
            };
         }
         _loc7_ = _loc5_;
         _loc6_ = (_loc5_ - _loc4_) / _loc5_;
         _loc8_ = RGBToHue(param1,param2,param3);
         return {
            "h":_loc8_,
            "s":_loc6_,
            "v":_loc7_
         };
      }
      
      public static function HSVtoRGB(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Number = (1 - param2) * param3;
         return HueToRGB(_loc4_,param3,param1);
      }
      
      public static function getAlpha(param1:uint) : uint
      {
         return param1 >> 24 & 0xFF;
      }
      
      public static function HSVtoHSL(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Object = HSVtoRGB(param1,param2,param3);
         return RGBtoHSL(_loc4_.r,_loc4_.g,_loc4_.b);
      }
      
      public static function getGreen(param1:uint) : uint
      {
         return param1 >> 8 & 0xFF;
      }
      
      public static function getColor24(param1:uint, param2:uint, param3:uint) : uint
      {
         return param1 << 16 | param2 << 8 | param3;
      }
      
      public static function getBlue(param1:uint) : uint
      {
         return param1 & 0xFF;
      }
      
      public static function HSLtoRGB(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Number = NaN;
         if(param2 < 0.5)
         {
            _loc4_ = param3 * param2;
         }
         else
         {
            _loc4_ = param3 * (1 - param2);
         }
         return HueToRGB(param2 - _loc4_,param2 + _loc4_,param1);
      }
      
      public static function getColor32(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         return param1 << 24 | param2 << 16 | param3 << 8 | param4;
      }
      
      private static function center(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param1 > param2 && param1 > param3)
         {
            if(param2 > param3)
            {
               return param2;
            }
            return param3;
         }
         if(param2 > param1 && param2 > param3)
         {
            if(param1 > param3)
            {
               return param1;
            }
            return param3;
         }
         if(param1 > param2)
         {
            return param1;
         }
         return param2;
      }
      
      public static function HSLtoHSV(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Object = HSLtoRGB(param1,param2,param3);
         return RGBtoHSV(_loc4_.r,_loc4_.g,_loc4_.b);
      }
      
      public static function RGBToHue(param1:Number, param2:Number, param3:Number) : uint
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         _loc7_ = Math.max(param1,Math.max(param2,param3));
         _loc5_ = Math.min(param1,Math.min(param2,param3));
         if(_loc7_ - _loc5_ == 0)
         {
            return 0;
         }
         _loc6_ = center(param1,param2,param3);
         if(param1 == _loc7_)
         {
            if(param3 == _loc5_)
            {
               _loc8_ = 0;
            }
            else
            {
               _loc8_ = 5;
            }
         }
         else if(param2 == _loc7_)
         {
            if(param3 == _loc5_)
            {
               _loc8_ = 1;
            }
            else
            {
               _loc8_ = 2;
            }
         }
         else if(param1 == _loc5_)
         {
            _loc8_ = 3;
         }
         else
         {
            _loc8_ = 4;
         }
         if(_loc8_ % 2 == 0)
         {
            _loc4_ = _loc6_ - _loc5_;
         }
         else
         {
            _loc4_ = _loc7_ - _loc6_;
         }
         _loc4_ /= _loc7_ - _loc5_;
         return 60 * (_loc8_ + _loc4_);
      }
      
      public static function RGBtoHSL(param1:Number, param2:Number, param3:Number) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = 0;
         _loc5_ = Math.max(param1,Math.max(param2,param3));
         _loc4_ = Math.min(param1,Math.min(param2,param3));
         _loc7_ = (_loc4_ + _loc5_) * 0.5;
         if(_loc7_ == 0)
         {
            return {
               "h":_loc9_,
               "l":0,
               "s":1
            };
         }
         _loc6_ = (_loc5_ - _loc4_) * 0.5;
         if(_loc7_ < 0.5)
         {
            _loc8_ = _loc6_ / _loc7_;
         }
         else
         {
            _loc8_ = _loc6_ / (1 - _loc7_);
         }
         _loc9_ = RGBToHue(param1,param2,param3);
         return {
            "h":_loc9_,
            "l":_loc7_,
            "s":_loc8_
         };
      }
      
      public static function getRed(param1:uint) : uint
      {
         return param1 >> 16 & 0xFF;
      }
   }
}

