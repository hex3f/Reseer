package com.robot.app.petGene
{
   public class PetGenePanelController
   {
      
      private static var _panel:PetGenePanel;
      
      public function PetGenePanelController()
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
         _panel = new PetGenePanel();
         _panel.show();
      }
   }
}

