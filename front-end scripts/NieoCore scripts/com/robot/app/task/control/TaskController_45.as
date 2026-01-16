package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.mode.AppModel;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskController_45
   {
      
      private static var icon:InteractiveObject;
      
      private static var lightMC:MovieClip;
      
      public static const TASK_ID:uint = 45;
      
      private static var panel:AppModel = null;
      
      public function TaskController_45()
      {
         super();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
         clickHandler();
      }
      
      public static function showIcon() : void
      {
         if(!icon)
         {
            icon = TaskIconManager.getIcon("icon_45");
            icon.addEventListener(MouseEvent.CLICK,clickHandler);
            ToolTipManager.add(icon,"领取NoNo");
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
            panel = new AppModel(ClientConfig.getTaskModule("ReceiveNoNo"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

