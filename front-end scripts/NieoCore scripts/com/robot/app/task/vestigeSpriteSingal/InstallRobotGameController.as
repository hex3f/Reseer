package com.robot.app.task.vestigeSpriteSingal
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class InstallRobotGameController
   {
      
      private static var panel:AppModel;
      
      public function InstallRobotGameController()
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
         panel = new AppModel(ClientConfig.getGameModule("InstallRobotGame"),"正在打开任务信息");
         panel.setup();
         panel.show();
      }
   }
}

