package com.robot.app.task.UnbelievableSpriteScholar
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class OpenTempleDoorController
   {
      
      private static var panel:AppModel;
      
      public function OpenTempleDoorController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("UnbelievableSpriteScholar/OpenTempleDoor"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

