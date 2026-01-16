package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpriteTrackController
   {
      
      private static var panel:AppModel;
      
      public function SpriteTrackController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getAppModule("NonoSpriteTrack"),"加载精灵追踪面板");
            panel.setup();
         }
         panel.show();
      }
   }
}

