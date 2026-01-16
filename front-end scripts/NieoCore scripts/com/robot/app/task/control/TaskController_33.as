package com.robot.app.task.control
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_33
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 33;
      
      private static var panel:AppModel = null;
      
      public function TaskController_33()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            showIcon();
         }
      }
      
      public static function start() : void
      {
         var _loc1_:String = "勇敢的小赛尔，你是一名坚强的战士，但是要记住，精灵的拯救才是我们这次的主要任务，不要恋战而耽误大事，据派特博士探测，精灵的体能已经过低，需要急救。";
         NpcTipDialog.show(_loc1_,accept,NpcTipDialog.INSTRUCTOR);
      }
      
      private static function accept() : void
      {
         TasksManager.accept(TASK_ID);
         showIcon();
      }
      
      public static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("icon_33");
            icon.addEventListener(MouseEvent.CLICK,clickHandler);
            ToolTipManager.add(icon,"解救被困的精灵们");
            lightMC = icon["lightMC"];
         }
         TaskIconManager.addIcon(icon);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
      }
      
      public static function clickHandler(param1:MouseEvent = null) : void
      {
         lightMC.gotoAndStop(lightMC.totalFrames);
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("RescueSprites"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

