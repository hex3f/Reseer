package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class ExploreStationController
   {
      
      private static var panel:AppModel;
      
      public function ExploreStationController()
      {
         super();
      }
      
      public static function showPanel(param1:String) : void
      {
         if(panel != null)
         {
            panel = null;
         }
         panel = ModuleManager.getModule(ClientConfig.getAppModule("ExploreStationManager"),"正在打开勘察站");
         panel.init(param1);
         panel.show();
      }
   }
}

