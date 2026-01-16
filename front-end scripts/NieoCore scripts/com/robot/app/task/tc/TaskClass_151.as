package com.robot.app.task.tc
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass_151
   {
      
      public function TaskClass_151(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(151,TasksManager.COMPLETE);
         var _loc2_:uint = uint(param1.monBallList[0].itemID);
         LevelManager.iconLevel.addChild(Alarm.show("你得到了1个" + TextFormatUtil.getRedTxt(ItemXMLInfo.getName(_loc2_)) + "。"));
      }
   }
}

