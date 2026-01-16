package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpriteElecTraController
   {
      
      private static var panel:AppModel;
      
      public function SpriteElecTraController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel != null)
         {
            panel = null;
         }
         panel = new AppModel(ClientConfig.getGameModule("SpriteElectricTraining"),"正在打开...");
         panel.setup();
         panel.show();
      }
   }
}

