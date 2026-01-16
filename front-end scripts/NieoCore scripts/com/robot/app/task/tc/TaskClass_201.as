package com.robot.app.task.tc
{
   import com.robot.app.task.SeerInstructor.NewInstructorContoller;
   import com.robot.app.task.SeerInstructor.SubmitInstructor;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.RelationManager;
   import com.robot.core.manager.TasksManager;
   
   public class TaskClass_201
   {
      
      public function TaskClass_201(param1:NoviceFinishInfo)
      {
         super();
         TasksManager.setTaskStatus(201,TasksManager.COMPLETE);
         MainManager.actorInfo.teacherID = 0;
         RelationManager.setOnLineFriend();
         NpcTipDialog.show("恭喜你通过了考核，现在颁发给你教官指挥棒，教官勋章。考察期过后，你可以正式招收学员。",NewInstructorContoller.delIcon,SubmitInstructor.instructor);
      }
   }
}

