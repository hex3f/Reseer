package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_407
   {
      
      public function TaskClass_407(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(407,TasksManager.COMPLETE);
         Alarm.show("看来你的利牙鱼牙齿比以前更加锋利了呢。2000点<font color=\'#ff0000\'>积累经验</font>已存入你的经验分配器中。");
      }
   }
}

