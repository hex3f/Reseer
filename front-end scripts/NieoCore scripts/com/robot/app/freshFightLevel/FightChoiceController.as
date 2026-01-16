package com.robot.app.freshFightLevel
{
   public class FightChoiceController
   {
      
      private static var panel:FightChoicePanel;
      
      public function FightChoiceController()
      {
         super();
      }
      
      private static function get getPanel() : FightChoicePanel
      {
         if(!panel)
         {
            panel = new FightChoicePanel();
         }
         return panel;
      }
      
      public static function show() : void
      {
         getPanel.show();
      }
      
      public static function hide() : void
      {
         getPanel.destroy();
      }
   }
}

