package com.robot.app.task.tc
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class TaskClass_30
   {
      
      public function TaskClass_30(param1:NoviceFinishInfo)
      {
         var info:NoviceFinishInfo = param1;
         super();
         TasksManager.setTaskStatus(30,TasksManager.COMPLETE);
         NpcTipDialog.show("答的不错，NoNo交给你我很放心。这些是给你的奖励！",function():void
         {
            var _loc1_:Object = null;
            var _loc2_:String = null;
            for each(_loc1_ in info.monBallList)
            {
               _loc2_ = ItemXMLInfo.getName(_loc1_.itemID);
               Alarm.show("恭喜你获得了" + _loc1_.itemCnt + "个<font color=\'#ff0000\'>" + _loc2_ + "</font>");
            }
         },NpcTipDialog.SHAWN);
      }
   }
}

