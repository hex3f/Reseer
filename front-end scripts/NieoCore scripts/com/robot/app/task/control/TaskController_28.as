package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_28
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 28;
      
      private static var panel:AppModel = null;
      
      public function TaskController_28()
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
            icon = TaskIconManager.getIcon("icon_28");
            icon.addEventListener(MouseEvent.CLICK,clickHandler);
            ToolTipManager.add(icon,"遗迹中的精灵信号");
            lightMC = icon["lightMC"];
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         lightMC.gotoAndStop(lightMC.totalFrames);
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("VestigeSpriteSingal"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

