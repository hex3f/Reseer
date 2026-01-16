package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_401
   {
      
      public function TaskClass_401(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(401,TasksManager.COMPLETE);
         var _loc2_:uint = uint(param1.monBallList[0]["itemCnt"]);
         Alarm.show("恭喜你获得<font color=\'#ff0000\'>" + _loc2_ + "点</font>补充经验，快回基地打开<font color=\'#ff0000\'>经验分配器</font>看看吧！");
      }
   }
}

