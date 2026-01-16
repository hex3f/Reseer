package com.robot.app.petSkin
{
   public class PetSkinPanelController
   {
      
      private static var _panel:PetSkinPanel;
      
      public function PetSkinPanelController()
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
         _panel = new PetSkinPanel();
         _panel.show();
      }
   }
}

