package com.robot.app.temp
{
   import org.taomee.utils.DisplayUtil;
   
   public class SpaceStationBuyController
   {
      
      private static var _panel:SpaceStationBuyPanel;
      
      public function SpaceStationBuyController()
      {
         super();
      }
      
      public static function get panel() : SpaceStationBuyPanel
      {
         if(_panel == null)
         {
            _panel = new SpaceStationBuyPanel();
         }
         return _panel;
      }
      
      public static function show() : void
      {
         if(!DisplayUtil.hasParent(panel))
         {
            panel.show();
         }
      }
   }
}

