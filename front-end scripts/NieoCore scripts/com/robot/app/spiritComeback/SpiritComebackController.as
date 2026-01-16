package com.robot.app.spiritComeback
{
   import com.robot.core.mode.AppModel;
   
   public class SpiritComebackController
   {
      
      private static var _AppOne:AppModel;
      
      private static var _AppTwo:AppModel;
      
      public function SpiritComebackController()
      {
         super();
      }
      
      private static function getSpirit() : void
      {
      }
      
      public static function showPanelOne() : void
      {
      }
      
      public static function hidePanelOne() : void
      {
      }
      
      public static function showPanelTwo() : void
      {
      }
      
      public static function hidePanelTwo() : void
      {
      }
      
      public static function destroy() : void
      {
         hidePanelOne();
         hidePanelTwo();
      }
   }
}

