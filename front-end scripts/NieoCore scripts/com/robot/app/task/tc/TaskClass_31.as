package com.robot.app.task.tc
{
   import com.robot.app.task.control.TaskController_31;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_31
   {
      
      private var itemID:uint;
      
      public function TaskClass_31(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(31,TasksManager.COMPLETE);
         TaskController_31.delIcon();
         var _loc2_:String = "现在，为你传送去的是<font color=\'#ff0000\'>赛尔特攻队服</font>。为了接下来的战斗，只有拥有最好的装备才能有最佳的战斗状态。";
         NpcTipDialog.show(_loc2_,this.receiveReward,NpcTipDialog.INSTRUCTOR,0,this.receiveReward);
      }
      
      private function receiveReward() : void
      {
         Alarm.show("<font color=\'#ff0000\'>赛尔特攻队服</font>已放入你的储存箱中.");
      }
   }
}

