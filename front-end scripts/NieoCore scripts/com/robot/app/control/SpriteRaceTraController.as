package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpriteRaceTraController
   {
      
      private static var panel:AppModel;
      
      public function SpriteRaceTraController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel != null)
         {
            panel = null;
         }
         panel = new AppModel(ClientConfig.getGameModule("SpriteRaceTraining"),"正在打开...");
         panel.setup();
         panel.show();
      }
   }
}

