package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_96;
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_96
   {
      
      public function TaskClass_96(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(96,TasksManager.COMPLETE);
         TaskController_96.destroy();
         MainManager.actorInfo.coins += 1000;
         Alarm.show("<font color=\'#ff0000\'>500积累经验</font>已经存入你的经验分配器中。",function():void
         {
            Alarm.show("<font color=\'#ff0000\'>1000赛尔豆</font>已放入了你的储存箱。",function():void
            {
               TasksController.taskCompleteUI();
            });
         });
      }
   }
}

