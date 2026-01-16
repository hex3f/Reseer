package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpriteFusionController
   {
      
      private static var panel:AppModel;
      
      public function SpriteFusionController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(panel != null)
         {
            panel.destroy();
            panel = null;
         }
         panel = new AppModel(ClientConfig.getAppModule("SpriteFusionPanel"),"正在打开...");
         panel.show();
      }
   }
}

