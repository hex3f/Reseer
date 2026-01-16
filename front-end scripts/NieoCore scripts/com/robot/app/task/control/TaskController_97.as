package com.robot.app.task.control
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.mode.AppModel;
   
   public class TaskController_97
   {
      
      public static var shot_grape_complete:Boolean = false;
      
      public static var get_kuangshi:Boolean = false;
      
      public static var help_dawei_complete:Boolean = false;
      
      public static var isShow:Boolean = false;
      
      public static const TASK_ID:uint = 97;
      
      private static var panel:AppModel = null;
      
      private static var taskPanel:AppModel = null;
      
      public function TaskController_97()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         var _loc1_:String = "TaskPanel_" + TASK_ID;
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
         panel = new AppModel(ClientConfig.getTaskModule(_loc1_),"正在打开任务信息");
         panel.setup();
         panel.show();
      }
      
      public static function setup() : void
      {
      }
      
      public static function start() : void
      {
      }
      
      public static function destroy() : void
      {
         if(Boolean(panel))
         {
            panel.destroy();
            panel = null;
         }
      }
   }
}

