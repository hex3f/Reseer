package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_93;
   import com.robot.app.task.control.TasksController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_93
   {
      
      public function TaskClass_93(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(93,TasksManager.COMPLETE);
         TaskController_93.destroy();
         MainManager.actorInfo.coins += 500;
         NpcDialog.show(NPC.MAOMAO,["哇哇哇哇！#8我们云霄星又恢复一片祥和咯！！小赛尔果然名不虚传哦！不错嘛！#6"],["哈哈……被你说的我都不好意思了！"],[function():void
         {
            Alarm.show("<font color=\'#ff0000\'>1000积累经验</font>已经存入你的经验分配器中。",function():void
            {
               Alarm.show("<font color=\'#ff0000\'>500赛尔豆</font>已放入了你的储存箱。",function():void
               {
                  TasksController.taskCompleteUI();
               });
            });
         }]);
      }
   }
}

