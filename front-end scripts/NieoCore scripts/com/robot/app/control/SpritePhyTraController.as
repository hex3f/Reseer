package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpritePhyTraController
   {
      
      private static var panel:AppModel;
      
      public function SpritePhyTraController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel != null)
         {
            panel = null;
         }
         panel = new AppModel(ClientConfig.getGameModule("SpritePhysicalTraining"),"正在打开...");
         panel.setup();
         panel.show();
      }
   }
}

