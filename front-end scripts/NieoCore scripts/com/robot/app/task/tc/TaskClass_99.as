package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   
   public class TaskClass_99
   {
      
      public function TaskClass_99(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(99,TasksManager.COMPLETE);
      }
   }
}

