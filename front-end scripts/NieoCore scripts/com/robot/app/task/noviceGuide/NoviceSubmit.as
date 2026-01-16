package com.robot.app.task.noviceGuide
{
   import com.robot.core.CommandID;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class NoviceSubmit
   {
      
      public static var taskOutInfo:NoviceFinishInfo;
      
      private static var _outId:uint;
      
      private static var _taskId:uint;
      
      public static const SUBMIT_TASK_OK:String = "submit_task_ok";
      
      public function NoviceSubmit()
      {
         super();
      }
      
      public static function set outId(param1:uint) : void
      {
         _outId = param1;
      }
      
      public static function set taskId(param1:uint) : void
      {
         _taskId = param1;
      }
      
      public static function submitTask() : void
      {
         SocketConnection.addCmdListener(CommandID.COMPLETE_TASK,onComplete);
         SocketConnection.send(CommandID.COMPLETE_TASK,_taskId,_outId);
      }
      
      private static function onComplete(param1:SocketEvent) : void
      {
         taskOutInfo = param1.data as NoviceFinishInfo;
         SocketConnection.removeCmdListener(CommandID.COMPLETE_TASK,onComplete);
         EventManager.dispatchEvent(new Event(SUBMIT_TASK_OK));
      }
   }
}

