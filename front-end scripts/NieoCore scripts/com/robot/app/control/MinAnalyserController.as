package com.robot.app.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   
   public class MinAnalyserController
   {
      
      private static var panel:AppModel;
      
      private static var arr:Array = [];
      
      public function MinAnalyserController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         TasksManager.getProStatusList(65,function(param1:Array):void
         {
            if(!param1[4])
            {
               arr.push(400023);
            }
            if(!param1[5])
            {
               arr.push(400024);
            }
            if(!param1[6])
            {
               arr.push(400025);
            }
         });
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getAppModule("MineralAnalyser"),"正在打开...");
            panel.init(arr);
         }
         panel.show();
      }
   }
}

