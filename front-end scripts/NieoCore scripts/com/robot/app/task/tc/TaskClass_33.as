package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_33;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_33
   {
      
      public function TaskClass_33(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(33,TasksManager.COMPLETE);
         TaskController_33.delIcon();
         var _loc2_:String = "宇宙海盗被我们赶走了，但是赛尔们不要掉以轻心，他们还像毒刺一样深深扎在美丽的宇宙当中，现在先让我来奖励完成任务的小英雄吧！";
         NpcTipDialog.show(_loc2_,this.getReward,NpcTipDialog.INSTRUCTOR,0,this.getReward);
      }
      
      private function getReward() : void
      {
         Alarm.show("华丽的<font color=\'#ff0000\'>天秤装</font>是赛尔勇士们独享的战斗服，收下它吧！",function():void
         {
            Alarm.show("<font color=\'#ff0000\'>天秤装</font>已放入你的储存箱中。");
         });
      }
   }
}

