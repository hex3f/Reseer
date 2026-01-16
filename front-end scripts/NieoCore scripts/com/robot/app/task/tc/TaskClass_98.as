package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_98;
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_98
   {
      
      public function TaskClass_98(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(98,TasksManager.COMPLETE);
         TaskController_98.destroy();
         MainManager.actorInfo.coins += 1000;
         NpcDialog.show(NPC.NIBU,["我最最幸福的就是能够来到赛尔号，能够感受到小赛尔们对我的关心！谢谢你们……"],["傻瓜！这都是我们应该的嘛！"],[function():void
         {
            Alarm.show("<font color=\'#ff0000\'>2000积累经验</font>已经存入你的经验分配器中。",function():void
            {
               Alarm.show("<font color=\'#ff0000\'>1000赛尔豆</font>已放入了你的储存箱。",function():void
               {
                  TasksController.taskCompleteUI();
               });
            });
         }]);
      }
   }
}

