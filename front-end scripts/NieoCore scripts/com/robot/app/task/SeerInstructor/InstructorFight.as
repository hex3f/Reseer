package com.robot.app.task.SeerInstructor
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.taskUtils.baseAction.GetTaskBuf;
   import com.robot.app.task.taskUtils.baseAction.SetTaskBuf;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.task.novice.NoviceBufInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import org.taomee.manager.EventManager;
   
   public class InstructorFight
   {
      
      private static var curBufInfo:NoviceBufInfo;
      
      private static var guard:String;
      
      private static var buf:String;
      
      public function InstructorFight()
      {
         super();
      }
      
      public static function startFight() : void
      {
         guard = NpcTipDialog.GUARD;
         if(TasksManager.taskList[200] != 1)
         {
            return;
         }
         getTaskBuf();
      }
      
      private static function onCloseFight(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
         var _loc2_:* = getDefinitionByName("com.robot.petFightModule.PetFightEntry") as Class;
         var _loc3_:FightOverInfo = param1.dataObj["data"];
         if(_loc3_.winnerID == MainManager.actorInfo.userID)
         {
            if(buf.indexOf("6") == -1)
            {
               SetTaskBuf.taskId = 201;
               SetTaskBuf.buf = buf + "6";
               SetTaskBuf.setBuf();
            }
         }
      }
      
      private static function getTaskBuf() : void
      {
         GetTaskBuf.taskId = 201;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
      }
      
      private static function onGetWasteOk(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
         buf = GetTaskBuf.buf;
         if(buf.indexOf("6") != -1)
         {
            NpcTipDialog.show("你完成了教官考核中的其他步骤吗，如果完成了赶紧去找教官雷蒙拿奖励吧！",null,guard,-40);
         }
         else
         {
            NpcTipDialog.show("参加教官考核的伙伴，准备好接受我的考验了吗？",onAccept,guard,-40);
         }
      }
      
      private static function onAccept() : void
      {
         FightInviteManager.fightWithBoss("NPC");
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
      }
   }
}

