package com.robot.app.sceneInteraction
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class PetStorageController
   {
      
      private static var _panel:AppModel;
      
      public function PetStorageController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(_panel == null)
         {
            _panel = ModuleManager.getModule(ClientConfig.getAppModule("PetStorage"),"正在打开精灵仓库");
            _panel.setup();
         }
         _panel.show();
      }
      
      public static function destroy() : void
      {
         if(Boolean(_panel))
         {
            _panel.destroy();
            _panel = null;
         }
      }
   }
}

