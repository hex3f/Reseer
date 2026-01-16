package com.robot.app.task.control
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   
   public class TaskController_37
   {
      
      private static var icon:InteractiveObject;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 37;
      
      public function TaskController_37()
      {
         super();
      }
      
      public static function start(param1:Boolean = false) : void
      {
         var b:Boolean = param1;
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            if(!b)
            {
               NpcTipDialog.show("星球测绘是非常繁琐复杂的工程，要细心一点，不要遗漏。给你的<font color=\'0xff0000\'>NoNo</font>装上<font color=\'0xff0000\'>星球测绘芯片</font>，它会在测绘过程中帮助你的。",function():void
               {
                  showTaskPanel();
               });
            }
         }
      }
      
      public static function showTaskPanel() : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getTaskModule("SpaceSurveyTask"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
      
      public static function showPanel() : void
      {
         showTaskPanel();
      }
   }
}

