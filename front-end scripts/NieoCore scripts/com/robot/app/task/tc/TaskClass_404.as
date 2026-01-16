package com.robot.app.task.tc
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   
   public class TaskClass_404
   {
      
      public function TaskClass_404(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(404,TasksManager.COMPLETE);
         var _loc2_:uint = uint(param1.monBallList[0]["itemCnt"]);
         var _loc3_:String = "呼~多亏了你和伊优的帮忙，海洋星才能恢复以往的清洁。你的伊优也乐在其中呢。伊优获得<font color=\'#ff0000\'>" + _loc2_ + "积累经验</font>，已经存入你的<font color=\'#ff0000\'>经验分配器</font>中。快回基地看看吧！";
         NpcTipDialog.show(_loc3_,null,NpcTipDialog.GUARD);
      }
   }
}

