package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class TaskController_95
   {
      
      public static var shot_grape_complete:Boolean = false;
      
      public static var get_kuangshi:Boolean = false;
      
      public static var help_dawei_complete:Boolean = false;
      
      public static var isShow:Boolean = false;
      
      public static const TASK_ID:uint = 95;
      
      private static var panel:AppModel = null;
      
      private static var taskPanel:AppModel = null;
      
      public function TaskController_95()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         var _loc1_:String = "TaskPanel_" + TASK_ID;
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule(_loc1_),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
         showTaskPanel(0);
      }
      
      public static function showTaskPanel(param1:uint) : void
      {
         var _loc2_:String = "TaskPanel0_" + TASK_ID;
         if(taskPanel != null)
         {
            taskPanel.destroy();
            taskPanel = null;
         }
         taskPanel = new AppModel(ClientConfig.getTaskModule(_loc2_),"正在打开任务信息");
         taskPanel.init(param1);
         taskPanel.show();
      }
   }
}

