package com.robot.app.complain
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.mode.AppModel;
   
   public class ComplainManager
   {
      
      private static var panel:AppModel;
      
      public function ComplainManager()
      {
         super();
      }
      
      public static function show(param1:UserInfo) : void
      {
         if(panel == null)
         {
            panel = ModuleManager.getModule(ClientConfig.getAppModule("ComplainPanel"),"正在打开举报系统");
            panel.setup();
         }
         panel.init(param1);
         panel.show();
      }
   }
}

