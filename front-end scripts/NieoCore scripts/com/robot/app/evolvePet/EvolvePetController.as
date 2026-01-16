package com.robot.app.evolvePet
{
   public class EvolvePetController
   {
      
      private static var _panel:EvolvePetPanel;
      
      public function EvolvePetController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(!_panel)
         {
            _panel = new EvolvePetPanel();
         }
         _panel.show();
      }
   }
}

