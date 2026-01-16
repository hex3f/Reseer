package com.robot.app.magicPassword
{
   public class MagicPasswordController
   {
      
      private static var magicPanel:MagicPasswordPanel;
      
      public function MagicPasswordController()
      {
         super();
      }
      
      public static function get getPanel() : MagicPasswordPanel
      {
         if(!magicPanel)
         {
            magicPanel = new MagicPasswordPanel();
         }
         return magicPanel;
      }
      
      public static function show() : void
      {
         getPanel.show();
      }
   }
}

