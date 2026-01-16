package com.robot.app.task.taskUtils.baseAction
{
   import com.robot.core.CommandID;
   import com.robot.core.info.task.TaskBufInfo;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class GetTaskBuf
   {
      
      public static var taskBuf:TaskBufInfo;
      
      public static var buf:String;
      
      public static var GET_TASK_BUF_OK:String = "get_task_bufok";
      
      public static var taskId:uint = 1;
      
      public function GetTaskBuf()
      {
         super();
      }
      
      public static function getBuf() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_TASK_BUF,onGetTaskBuf);
         SocketConnection.send(CommandID.GET_TASK_BUF,taskId);
      }
      
      private static function onGetTaskBuf(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GET_TASK_BUF,onGetTaskBuf);
         taskBuf = param1.data as TaskBufInfo;
         try
         {
            buf = taskBuf.buf.readUTFBytes(20);
            EventManager.dispatchEvent(new Event(GET_TASK_BUF_OK));
         }
         catch(e:Error)
         {
         }
      }
   }
}

