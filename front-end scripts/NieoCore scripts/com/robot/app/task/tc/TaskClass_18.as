package com.robot.app.task.tc
{
   import com.robot.app.task.makeBase.MakeBase;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   
   public class TaskClass_18
   {
      
      public function TaskClass_18(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(MakeBase.TASK_ID,TasksManager.COMPLETE);
         MakeBase.delIcon();
         NpcTipDialog.show("3000点<font color=\'#ff0000\'>积累经验</font>已存入你的经验分配器中。",null,NpcTipDialog.CICI);
      }
   }
}

