package com.robot.app.WheelChoice
{
   public class WheelChoicePanelController
   {
      
      private static var _panel:WheelChoiceUI;
      
      public function WheelChoicePanelController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(_panel != null)
         {
            _panel.destroy();
            _panel = null;
         }
         _panel = new WheelChoiceUI();
         _panel.show();
      }
   }
}

