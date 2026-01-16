package com.robot.app.task.SeerInstructor
{
   import com.robot.app.task.taskUtils.baseAction.AcceptTask;
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   import org.taomee.manager.EventManager;
   
   public class SeerInstructorMain
   {
      
      private static var _loader:MCLoader;
      
      private static var PATH:String = "resource/task/instructor/seerInstructor.swf";
      
      public function SeerInstructorMain()
      {
         super();
      }
      
      public static function talkToInstructor(param1:Boolean = false) : void
      {
         var _loc2_:String = NpcTipDialog.INSTRUCTOR;
         switch(TasksManager.taskList[200])
         {
            case 0:
               if(param1)
               {
                  onAccept();
                  break;
               }
               NpcDialog.show(NPC.LYMAN,["你还没有参加报名赛尔号教官考核呢！"],["知道啦..."]);
               break;
            case 1:
               if(param1)
               {
                  NpcDialog.show(NPC.LYMAN,["你已经通过教官预考了，请尽快去完成考核任务呢！"],["知道啦..."]);
                  break;
               }
               SubmitInstructor.start();
               break;
            case 2:
               if(param1)
               {
                  SeerInstructorMain.start();
                  break;
               }
               NpcDialog.show(NPC.LYMAN,["你还没有参加报名赛尔号教官考核呢！"],["知道啦..."]);
               break;
            case 3:
               NpcDialog.show(NPC.LYMAN,["你已经通过了预考并完成了教官考核，现在可以去招收学员了。"],["知道啦..."]);
         }
      }
      
      private static function onAccept() : void
      {
         if(TasksManager.taskList[300] != 3)
         {
            NpcDialog.show(NPC.LYMAN,["非常抱歉，你不符合条件，所以不能参加考试哦。快去完成蘑菇怪任务。"],["知道啦..."]);
         }
         else
         {
            InstructorExam.loadGame();
         }
      }
      
      public static function start() : void
      {
         if(TasksManager.taskList[200] != 2)
         {
            return;
         }
         AcceptTask.taskId = 201;
         AcceptTask.acceptTask();
         EventManager.addEventListener(AcceptTask.ACCEPT_TASK_OK,acceptTask);
      }
      
      private static function acceptTask(param1:Event) : void
      {
         EventManager.removeEventListener(AcceptTask.ACCEPT_TASK_OK,acceptTask);
         loadIntructorTaskUI();
      }
      
      public static function loadIntructorTaskUI() : void
      {
         if(TasksManager.taskList[200] != 1)
         {
            return;
         }
         _loader = new MCLoader(PATH,LevelManager.topLevel,1,"正在加载教官任务资源");
         _loader.addEventListener(MCLoadEvent.SUCCESS,onComplete);
         _loader.doLoad();
      }
      
      private static function onComplete(param1:MCLoadEvent) : void
      {
         _loader.removeEventListener(MCLoadEvent.SUCCESS,onComplete);
         var _loc2_:ApplicationDomain = param1.getApplicationDomain();
         TaskUIManage.loadHash.add(201,param1.getLoader());
         InstructorIcon.show();
      }
   }
}

