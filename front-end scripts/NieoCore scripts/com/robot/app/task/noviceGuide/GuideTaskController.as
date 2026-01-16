package com.robot.app.task.noviceGuide
{
   import com.robot.app.task.noviceGuide.GuideTaskAfter.GuidTaskAfterPanel;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.ui.alert.Alarm;
   
   public class GuideTaskController
   {
      
      private static var guideTaskPanel:GuideTaskPanel;
      
      private static var guideTaskAfterPanel:GuidTaskAfterPanel;
      
      public function GuideTaskController()
      {
         super();
      }
      
      public static function showPanel() : void
      {
         if(guideTaskPanel != null)
         {
            guideTaskPanel = null;
         }
         if(guideTaskAfterPanel != null)
         {
            guideTaskAfterPanel = null;
         }
         if(TasksManager.taskList[2] == 3)
         {
            if(MainManager.actorInfo.mapID != 8)
            {
               Alarm.show("想要完成新手任务，你需要先到机械室找到茜茜哦！");
               return;
            }
            guideTaskAfterPanel = new GuidTaskAfterPanel();
            guideTaskAfterPanel.show();
         }
         else
         {
            guideTaskPanel = new GuideTaskPanel();
            guideTaskPanel.show();
         }
      }
   }
}

