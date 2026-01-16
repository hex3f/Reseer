package com.robot.app.task.skeeClothTask
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.mode.AppModel;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class SkeeClothTaskController
   {
      
      private static var icon:SimpleButton;
      
      private static var panel:AppModel;
      
      private static var shiperMC:MovieClip;
      
      public static const TASK_ID:uint = 7;
      
      public function SkeeClothTaskController()
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
      
      private static function showIcon() : void
      {
         if(!icon)
         {
            icon = UIManager.getButton("SkeeCloth_Icon");
            ToolTipManager.add(icon,"防寒套装制作");
         }
         TaskIconManager.addIcon(icon);
         icon.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      public static function delIcon() : void
      {
         TaskIconManager.delIcon(icon);
         ToolTipManager.remove(icon);
      }
      
      private static function clickHandler(param1:MouseEvent) : void
      {
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getTaskModule("SkeeCloth"),"正在打开任务信息");
            panel.setup();
         }
         panel.show();
      }
   }
}

