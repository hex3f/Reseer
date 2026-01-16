package com.robot.app.task.AilixunIntrudeTask
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class AilixunIntrudeController
   {
      
      private static var shiperMC:MovieClip;
      
      public static const TASK_ID:uint = 15;
      
      private static var icon:SimpleButton = null;
      
      private static var panel:AppModel = null;
      
      public function AilixunIntrudeController()
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
         if(TasksManager.getTaskStatus(TASK_ID) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(TASK_ID,onAccept);
         }
      }
      
      private static function onAccept(param1:Boolean) : void
      {
         if(param1)
         {
            showIcon();
         }
         else
         {
            Alarm.show("你还没有完成新手任务！");
         }
      }
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getButton("AilixunIntrude_Icon");
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("AilixunIntrude"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

