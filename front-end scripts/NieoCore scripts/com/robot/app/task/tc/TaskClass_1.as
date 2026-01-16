package com.robot.app.task.tc
{
   import com.robot.app.RegisterCode.GetRegisterCode;
   import com.robot.app.task.books.TimesNewPanel;
   import com.robot.app.task.noviceGuide.GuideTaskController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import flash.events.MouseEvent;
   
   public class TaskClass_1
   {
      
      public function TaskClass_1(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(1,TasksManager.COMPLETE);
      }
      
      private static function showGuideTaskPanel() : void
      {
         TimesNewPanel.messageIcon = UIManager.getMovieClip("Message_Icon_2");
         TimesNewPanel.messageIcon.buttonMode = true;
         TimesNewPanel.messageIcon.x = 180;
         TimesNewPanel.messageIcon.y = 20;
         LevelManager.iconLevel.addChild(TimesNewPanel.messageIcon);
         TimesNewPanel.messageIcon.addEventListener(MouseEvent.CLICK,showRequest);
         if(TasksManager.getTaskStatus(2) == TasksManager.COMPLETE)
         {
            GuideTaskController.showPanel();
         }
      }
      
      private static function showRequest(param1:MouseEvent) : void
      {
         LevelManager.iconLevel.removeChild(TimesNewPanel.messageIcon);
         GetRegisterCode.getCode();
         TimesNewPanel.messageIcon = null;
      }
   }
}

