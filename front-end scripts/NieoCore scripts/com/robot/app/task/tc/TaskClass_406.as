package com.robot.app.task.tc
{
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass_406
   {
      
      public function TaskClass_406(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(406,TasksManager.COMPLETE);
         var _loc2_:String = "不错嘛！果然好眼力，连神出鬼没的幽浮都拿你没辙噢。" + TextFormatUtil.getRedTxt("2000积累经验") + "已经放入你的" + TextFormatUtil.getRedTxt("经验分配器") + "内。";
         Alarm.show(_loc2_);
      }
   }
}

