package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.taskUtils.baseAction.AcceptTask;
   import com.robot.core.manager.TasksManager;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class DoGuideTask
   {
      
      public function DoGuideTask()
      {
         super();
      }
      
      public static function doTask() : void
      {
         if(TasksManager.taskList[2] != 0)
         {
            return;
         }
         AcceptTask.taskId = 3;
         AcceptTask.acceptTask();
         EventManager.addEventListener(AcceptTask.ACCEPT_TASK_OK,onAcceptOK3);
      }
      
      private static function onAcceptOK3(param1:Event) : void
      {
         EventManager.removeEventListener(AcceptTask.ACCEPT_TASK_OK,onAcceptOK3);
         TasksManager.taskList[2] = 1;
         GuideTaskModel.checkTaskStatus();
         GuideTaskModel.setTaskBuf("9");
      }
   }
}

