package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   
   public class TaskController_94
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 94;
      
      private static var panel:AppModel = null;
      
      public function TaskController_94()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_94"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
      }
      
      public static function showIcon() : void
      {
      }
      
      public static function delIcon() : void
      {
      }
   }
}

