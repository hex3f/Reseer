package com.robot.app.worldMap
{
   import org.taomee.utils.DisplayUtil;
   
   public class WorldMapController
   {
      
      private static var _worldMap:WorldMapPanel;
      
      public function WorldMapController()
      {
         super();
      }
      
      private static function get worldMap() : WorldMapPanel
      {
         if(!_worldMap)
         {
            _worldMap = new WorldMapPanel();
         }
         return _worldMap;
      }
      
      public static function show() : void
      {
         if(!DisplayUtil.hasParent(worldMap))
         {
            worldMap.show();
         }
      }
   }
}

