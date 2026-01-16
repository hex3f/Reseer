package com.robot.app.worldMap
{
   import org.taomee.utils.DisplayUtil;
   
   public class ShipMapController
   {
      
      private static var _shipMap:ShipMapWin;
      
      public function ShipMapController()
      {
         super();
      }
      
      private static function get shipMap() : ShipMapWin
      {
         if(!_shipMap)
         {
            _shipMap = new ShipMapWin();
         }
         return _shipMap;
      }
      
      public static function show() : void
      {
         if(!DisplayUtil.hasParent(shipMap))
         {
            shipMap.show();
         }
      }
   }
}

