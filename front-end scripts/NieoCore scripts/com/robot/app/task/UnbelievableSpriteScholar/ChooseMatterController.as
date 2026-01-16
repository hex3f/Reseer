package com.robot.app.task.UnbelievableSpriteScholar
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class ChooseMatterController
   {
      
      private static var panel:AppModel;
      
      public function ChooseMatterController()
      {
         super();
      }
      
      public static function show() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("UnbelievableSpriteScholar/ChooseMatterPanel"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

