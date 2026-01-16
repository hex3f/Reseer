package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_45;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_45
   {
      
      public function TaskClass_45(param1:NoviceFinishInfo)
      {
         var i:NoviceFinishInfo = param1;
         super();
         TaskController_45.delIcon();
         TasksManager.setTaskStatus(45,TasksManager.COMPLETE);
         NpcTipDialog.show("你完成得非常好哦，NoNo还有很多的功能等待你去发现和应用，继续努力吧！\r    这是给你的奖励。",function():void
         {
            Alarm.show("恭喜你获得了3000赛尔豆！");
            MainManager.actorInfo.coins += 3000;
         },NpcTipDialog.CICI);
      }
   }
}

