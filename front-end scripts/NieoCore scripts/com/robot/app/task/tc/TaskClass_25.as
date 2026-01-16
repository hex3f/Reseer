package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_25;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_25
   {
      
      public function TaskClass_25(param1:NoviceFinishInfo)
      {
         super();
         TaskController_25.delIcon();
         TasksManager.setTaskStatus(TaskController_25.TASK_ID,TasksManager.COMPLETE);
         ItemInBagAlert.show(400501,"10个扭蛋牌已经放入你的储存箱");
      }
   }
}

