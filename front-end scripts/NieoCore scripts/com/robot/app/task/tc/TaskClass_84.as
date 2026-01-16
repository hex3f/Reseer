package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import flash.display.MovieClip;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskClass_84
   {
      
      public function TaskClass_84(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(84,TasksManager.COMPLETE);
         MainManager.actorInfo.coins += 2000;
         Alarm.show("<font color=\'#ff0000\'>2000积累经验</font>已经存入你的经验分配器中。",this.showTip);
      }
      
      private function showTip() : void
      {
         ItemInBagAlert.show(1,"<font color=\'#ff0000\'>2000</font>赛尔豆已放入了你的储存箱。",this.addOverUI);
      }
      
      private function addOverUI() : void
      {
         var taskmc:MovieClip = null;
         taskmc = null;
         var endTask:Function = null;
         endTask = function():void
         {
            taskmc.addFrameScript(taskmc.totalFrames - 1,null);
            DisplayUtil.removeForParent(taskmc);
            taskmc = null;
         };
         taskmc = TaskIconManager.getIcon("TaskOverUI") as MovieClip;
         DisplayUtil.align(taskmc,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(taskmc);
         taskmc.addFrameScript(taskmc.totalFrames - 1,endTask);
      }
   }
}

