package com.robot.app.task.control
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import flash.display.MovieClip;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TasksController
   {
      
      public static const TASKPANEL_SHOW_COMPLETE:String = "taskPanel_show_complete";
      
      public static const TASKPANEL_SHOW_PAUSE:String = "taskPanel_show_pause";
      
      public static const TASKPANEL_CLOSE:String = "taskPanel_close";
      
      public function TasksController()
      {
         super();
      }
      
      public static function taskCompleteUI() : void
      {
         var taskmc:MovieClip = null;
         taskmc = null;
         var endTask:Function = null;
         endTask = function():void
         {
            taskmc.addFrameScript(taskmc.totalFrames - 1,null);
            DisplayUtil.removeForParent(taskmc);
            taskmc = null;
         };
         taskmc = TaskIconManager.getIcon("TaskOverUI") as MovieClip;
         DisplayUtil.align(taskmc,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(taskmc);
         taskmc.addFrameScript(taskmc.totalFrames - 1,endTask);
      }
   }
}

