package com.robot.app.task.taskUtils.baseAction
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class DeleteTask
   {
      
      private static var _taskId:uint;
      
      public static const DELETE_TASK_OK:String = "DELETE_TASK_OK";
      
      public function DeleteTask()
      {
         super();
      }
      
      public static function set taskId(param1:uint) : void
      {
         _taskId = param1;
      }
      
      public static function delTask() : void
      {
         SocketConnection.addCmdListener(CommandID.DELETE_TASK,onDelete);
         SocketConnection.send(CommandID.DELETE_TASK,_taskId);
      }
      
      private static function onDelete(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.DELETE_TASK,onDelete);
         TasksManager.taskList[_taskId - 1] = 2;
         EventManager.dispatchEvent(new Event(DELETE_TASK_OK));
      }
   }
}

