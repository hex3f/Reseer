package com.robot.app.oldPaper
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class OldNewsPaperController
   {
      
      private static var _panel:AppModel;
      
      public function OldNewsPaperController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(!_panel)
         {
            _panel = ModuleManager.getModule(ClientConfig.getAppModule("OldNewsPaper"),"正在打开日志列表");
            _panel.setup();
         }
         _panel.show();
      }
   }
}

