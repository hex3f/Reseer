package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   
   public class TaskClass_95
   {
      
      public function TaskClass_95(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(95,TasksManager.COMPLETE);
         MainManager.actorInfo.coins += 2000;
         Alarm.show("<font color=\'#ff0000\'>4000积累经验</font>已经存入你的经验分配器中。",function():void
         {
            ItemInBagAlert.show(1,"<font color=\'#ff0000\'>2000</font>赛尔豆已放入了你的储存箱。",function():void
            {
               var o:Object = null;
               for each(o in info.monBallList)
               {
                  if(o["itemID"] == 100346)
                  {
                     Alarm.show("<font color=\'#ff0000\'>刺蜂套装</font>已放入了你的储存箱。",function():void
                     {
                        TasksController.taskCompleteUI();
                     });
                     return;
                  }
               }
               Alarm.show("<font color=\'#ff0000\'>锡蝶套装</font>已放入了你的储存箱。",function():void
               {
                  TasksController.taskCompleteUI();
               });
            });
         });
      }
   }
}

