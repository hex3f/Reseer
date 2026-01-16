package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_37;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass_37
   {
      
      public function TaskClass_37(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(TaskController_37.TASK_ID,TasksManager.COMPLETE);
         NpcTipDialog.show("星球测绘是非常繁琐复杂的工程，能够如此出色迅速得完成这项工程，真是非常优秀的小赛尔啊，这是给你的奖励！",function():void
         {
            Alarm.show("<font color=\'#ff0000\'>星球勘察装</font>套装已经放入你的储存箱！",function():void
            {
               ItemInBagAlert.show(1,"<font color=\'#ff0000\'>3000</font>赛尔豆已放入了你的储存箱。",function():void
               {
                  Alarm.show(TextFormatUtil.getRedTxt("中型智慧芯片") + "已放入你超能NoNo的储藏空间中。");
               });
               MainManager.actorInfo.coins += 3000;
            });
         },NpcTipDialog.SHIPER);
      }
   }
}

