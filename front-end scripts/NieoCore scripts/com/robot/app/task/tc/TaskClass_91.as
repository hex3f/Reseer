package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_91
   {
      
      public function TaskClass_91(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(91,TasksManager.COMPLETE);
         MainManager.actorInfo.coins += 2000;
         Alarm.show("<font color=\'#ff0000\'>2000积累经验</font>已经存入你的经验分配器中。",function():void
         {
            ItemInBagAlert.show(1,"<font color=\'#ff0000\'>2000</font>赛尔豆已放入了你的储存箱。",function():void
            {
               ItemInBagAlert.show(400124,"一个<font color=\'#ff0000\'>神秘精元</font>已放入了你的储存箱。",function():void
               {
                  TasksController.taskCompleteUI();
               });
            });
         });
      }
   }
}

