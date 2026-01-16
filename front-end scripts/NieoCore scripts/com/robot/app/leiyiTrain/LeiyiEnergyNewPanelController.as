package com.robot.app.leiyiTrain
{
   public class LeiyiEnergyNewPanelController
   {
      
      private static var _panel:LeiyiEnergyNewPanel;
      
      public function LeiyiEnergyNewPanelController()
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
         _panel = new LeiyiEnergyNewPanel();
         _panel.show();
      }
   }
}

