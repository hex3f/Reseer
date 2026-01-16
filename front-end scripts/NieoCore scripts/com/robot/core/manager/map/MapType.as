package com.robot.core.manager.map
{
   import org.taomee.ds.HashMap;
   
   public class MapType
   {
      
      private static var hashMap:HashMap;
      
      public static const HOOM:int = 0;
      
      public static const CAMP:int = 101;
      
      public static const HEAD:int = 102;
      
      public static const FB:int = 201;
      
      public static const TEMP_HOME:int = 100;
      
      public static const TEMP_CAMP:int = 105;
      
      public static const PK_TYPE:uint = 103;
      
      setup();
      
      public function MapType()
      {
         super();
      }
      
      private static function setup() : void
      {
         hashMap = new HashMap();
         hashMap.add(501,201);
         hashMap.add(502,202);
         hashMap.add(515,204);
      }
      
      public static function getFbTypeID(param1:uint) : uint
      {
         return hashMap.getValue(param1);
      }
   }
}

