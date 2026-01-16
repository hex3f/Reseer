package com.robot.app.task.pirateFortFight
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class SpiderThunderController
   {
      
      private static var panel:AppModel;
      
      public function SpiderThunderController()
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
         panel = new AppModel(ClientConfig.getGameModule("SpiderThunderGame"),"正在打开任务信息");
         panel.setup();
      }
   }
}

