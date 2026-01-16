package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   
   public class TaskClass_4
   {
      
      public function TaskClass_4(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(4,TasksManager.COMPLETE);
      }
   }
}

