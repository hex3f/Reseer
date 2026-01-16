package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_89;
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_89
   {
      
      public function TaskClass_89(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(89,TasksManager.COMPLETE);
         TaskController_89.destroy();
         MainManager.actorInfo.coins += 1000;
         NpcDialog.show(NPC.LYMAN,["哈哈！不错啊！果然青出于蓝胜于蓝！你和你的精灵伙伴都做的很棒！赛尔号的旅程才刚刚开始，你可能会经历更多的磨练和考验哦！"],["我会以最佳的状态迎接新的挑战！"],[function():void
         {
            Alarm.show("<font color=\'#ff0000\'>500积累经验</font>已经存入你的经验分配器中。",function():void
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

