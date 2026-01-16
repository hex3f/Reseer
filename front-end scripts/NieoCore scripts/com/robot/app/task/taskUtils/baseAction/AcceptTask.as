package com.robot.app.task.taskUtils.baseAction
{
   import com.robot.core.CommandID;
   import com.robot.core.info.task.novice.NoviceBufInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class AcceptTask
   {
      
      private static var _taskId:uint;
      
      private static var taskBuf:NoviceBufInfo;
      
      public static const ACCEPT_TASK_OK:String = "ACCEPT_TASK_OK";
      
      public function AcceptTask()
      {
         super();
      }
      
      public static function set taskId(param1:uint) : void
      {
         _taskId = param1;
      }
      
      public static function acceptTask() : void
      {
         SocketConnection.addCmdListener(CommandID.ACCEPT_TASK,onAccept);
         SocketConnection.send(CommandID.ACCEPT_TASK,_taskId);
      }
      
      private static function onAccept(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.ACCEPT_TASK,onAccept);
         TasksManager.taskList[_taskId - 1] = 1;
         EventManager.dispatchEvent(new Event(ACCEPT_TASK_OK));
      }
   }
}

