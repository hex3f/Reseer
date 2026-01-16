package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpritePieceTogeController
   {
      
      private static var panel:AppModel;
      
      public function SpritePieceTogeController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getGameModule("SpritePieceTogether"),"正在打开...");
            panel.setup();
         }
         panel.show();
      }
   }
}

