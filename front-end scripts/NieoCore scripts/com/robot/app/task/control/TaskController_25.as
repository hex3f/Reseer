package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_25
   {
      
      private static var icon:InteractiveObject;
      
      private static var panel:AppModel;
      
      public static const TASK_ID:uint = 25;
      
      public function TaskController_25()
      {
         super();
      }
      
      public static function start() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("new_player_icon");
            icon.addEventListener(MouseEvent.CLICK,showTaskPanel);
            ToolTipManager.add(icon,"新船员的考验");
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         ToolTipManager.remove(icon);
         TaskIconManager.delIcon(icon);
         icon.removeEventListener(MouseEvent.CLICK,showTaskPanel);
         icon = null;
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
      
      private static function showTaskPanel(param1:MouseEvent) : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getTaskModule("NewPlayerTraining"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

