package com.robot.core.utils
{
   import flash.geom.Point;
   import org.taomee.utils.GeomUtil;
   
   public class Direction
   {
      
      public static var UP:String = "up";
      
      public static var DOWN:String = "down";
      
      public static var LEFT:String = "left";
      
      public static var LEFT_UP:String = "leftup";
      
      public static var LEFT_DOWN:String = "leftdown";
      
      public static var RIGHT:String = "right";
      
      public static var RIGHT_UP:String = "rightup";
      
      public static var RIGHT_DOWN:String = "rightdown";
      
      public static var LIST:Array = [RIGHT,RIGHT_DOWN,DOWN,LEFT_DOWN,LEFT,LEFT_UP,UP,RIGHT_UP];
      
      public function Direction()
      {
         super();
      }
      
      public static function indexToStr(param1:int) : String
      {
         return LIST[param1];
      }
      
      public static function strToIndex(param1:String) : int
      {
         return LIST.indexOf(param1);
      }
      
      public static function getIndex(param1:Point, param2:Point) : int
      {
         return angleToIndex(GeomUtil.pointAngle(param1,param2));
      }
      
      public static function getStr(param1:Point, param2:Point) : String
      {
         return indexToStr(getIndex(param1,param2));
      }
      
      public static function angleToIndex(param1:Number) : int
      {
         param1 = param1 + 22.5 + 180;
         if(param1 > 360)
         {
            param1 = 0;
         }
         return int(param1 / 45);
      }
      
      public static function angleToStr(param1:Number) : String
      {
         return indexToStr(angleToIndex(param1));
      }
   }
}

