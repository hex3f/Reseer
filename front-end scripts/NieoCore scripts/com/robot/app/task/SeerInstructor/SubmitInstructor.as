package com.robot.app.task.SeerInstructor
{
   import com.robot.app.task.taskUtils.baseAction.GetTaskBuf;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class SubmitInstructor
   {
      
      public static var instructor:String;
      
      public function SubmitInstructor()
      {
         super();
      }
      
      public static function start() : void
      {
         instructor = NpcTipDialog.INSTRUCTOR;
         GetTaskBuf.taskId = 201;
         GetTaskBuf.getBuf();
         EventManager.addEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
      }
      
      private static function onGetWasteOk(param1:Event) : void
      {
         EventManager.removeEventListener(GetTaskBuf.GET_TASK_BUF_OK,onGetWasteOk);
         var _loc2_:String = GetTaskBuf.buf;
         if(_loc2_.length == 6)
         {
            SocketConnection.send(CommandID.COMPLETE_TASK,201,1);
         }
         else
         {
            NpcDialog.show(NPC.LYMAN,["你还没有完成教官考核，请仔细查看教官考核任务要求，加油！"],["知道啦..."]);
         }
      }
   }
}

