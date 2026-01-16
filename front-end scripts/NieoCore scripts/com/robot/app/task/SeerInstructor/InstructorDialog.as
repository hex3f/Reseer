package com.robot.app.task.SeerInstructor
{
   import com.robot.app.teacher.TeacherSysManager;
   import com.robot.app.teacherAward.TeacherAwardModel;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class InstructorDialog
   {
      
      private static var mc:MovieClip;
      
      private static var signBtn:SimpleButton;
      
      private static var awardBtn:SimpleButton;
      
      private static var removeBtn:SimpleButton;
      
      private static var exitBtn:SimpleButton;
      
      public function InstructorDialog()
      {
         super();
      }
      
      public static function show() : void
      {
         showDialog();
      }
      
      private static function showDialog() : void
      {
         NpcDialog.show(NPC.LYMAN,["你好，我是赛尔号的总教官雷蒙，我主要负责把新加入的小赛尔们训练成赛尔精英！我希望你可以通过报名考试来获得教官资格！"],["我这就报名考试！","我是来领取奖励的。","我希望可以和我的学员解除关系。"],[handler1,handler2,handler3]);
      }
      
      private static function handler1() : void
      {
         signHander();
      }
      
      private static function handler2() : void
      {
         awardHander();
      }
      
      private static function handler3() : void
      {
         removeHander();
      }
      
      private static function signHander(param1:MouseEvent = null) : void
      {
         SeerInstructorMain.talkToInstructor(true);
      }
      
      private static function awardHander(param1:MouseEvent = null) : void
      {
         if(TasksManager.taskList[200] == 3)
         {
            TeacherAwardModel.sendCmd();
         }
         else
         {
            SeerInstructorMain.talkToInstructor();
         }
      }
      
      private static function removeHander(param1:MouseEvent = null) : void
      {
         if(MainManager.actorInfo.teacherID == 0 && MainManager.actorInfo.studentID == 0)
         {
            NpcDialog.show(NPC.LYMAN,["你还没有与别人建立教官或学员的关系哦！"],["知道啦..."]);
            return;
         }
         if(MainManager.actorInfo.teacherID != 0)
         {
            TeacherSysManager.delTeacher();
         }
         else if(MainManager.actorInfo.studentID != 0)
         {
            TeacherSysManager.delStudent();
         }
      }
   }
}

