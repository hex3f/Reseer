package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class TaskController_83
   {
      
      public static var panel:AppModel = null;
      
      public function TaskController_83()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("TaskPanel_83"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
         showPanel();
      }
      
      public static function showIcon() : void
      {
      }
      
      public static function delIcon() : void
      {
      }
   }
}

