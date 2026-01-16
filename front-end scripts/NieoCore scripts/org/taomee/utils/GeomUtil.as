package org.taomee.utils
{
   import flash.geom.Point;
   
   public class GeomUtil
   {
      
      public static const R_T_D:Number = 180 / Math.PI;
      
      public static const D_T_R:Number = Math.PI / 180;
      
      public function GeomUtil()
      {
         super();
      }
      
      public static function radiansToDegrees(param1:Number) : Number
      {
         return param1 * R_T_D;
      }
      
      public static function pointAngle(param1:Point, param2:Point) : Number
      {
         return Math.atan2(param1.y - param2.y,param1.x - param2.x) * R_T_D;
      }
      
      public static function pointRadians(param1:Point, param2:Point) : Number
      {
         return Math.atan2(param1.y - param2.y,param1.x - param2.x);
      }
      
      public static function getCirclePoint(param1:Point, param2:Number, param3:Number) : Point
      {
         var _loc4_:Number = param2 * D_T_R;
         return param1.add(new Point(Math.cos(_loc4_) * param3,Math.sin(_loc4_) * param3));
      }
      
      public static function degreesToRadians(param1:Number) : Number
      {
         return param1 * D_T_R;
      }
      
      public static function angleSpeed(param1:Point, param2:Point) : Point
      {
         var _loc3_:Number = Math.atan2(param1.y - param2.y,param1.x - param2.x);
         return new Point(Math.cos(_loc3_),Math.sin(_loc3_));
      }
      
      public static function angleToSpeed(param1:Number) : Point
      {
         var _loc2_:Number = param1 * D_T_R;
         return new Point(Math.cos(_loc2_),Math.sin(_loc2_));
      }
      
      public static function radiansToSpeed(param1:Number) : Point
      {
         return new Point(Math.cos(param1),Math.sin(param1));
      }
   }
}

