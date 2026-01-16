package org.taomee.utils
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class BitmapDataUtil
   {
      
      public function BitmapDataUtil()
      {
         super();
      }
      
      public static function makeList(param1:BitmapData, param2:int, param3:int, param4:uint, param5:Boolean = false) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:BitmapData = null;
         var _loc9_:int = int(Math.min(param1.width,2880) / param2);
         var _loc10_:int = int(Math.min(param1.height,2880) / param3);
         var _loc11_:int = 0;
         var _loc12_:Array = [];
         var _loc13_:Rectangle = new Rectangle(0,0,param2,param3);
         var _loc14_:Point = new Point();
         _loc7_ = 0;
         while(_loc7_ < _loc10_)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc9_)
            {
               if(_loc11_ >= param4)
               {
                  return _loc12_;
               }
               _loc13_.x = _loc6_ * param2;
               _loc13_.y = _loc7_ * param3;
               _loc8_ = new BitmapData(param2,param3);
               _loc8_.copyPixels(param1,_loc13_,_loc14_);
               _loc12_[_loc11_] = _loc8_;
               _loc11_++;
               _loc6_++;
            }
            _loc7_++;
         }
         if(param5)
         {
            param1.dispose();
         }
         return _loc12_;
      }
   }
}

