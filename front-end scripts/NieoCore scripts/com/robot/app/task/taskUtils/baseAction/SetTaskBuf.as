package com.robot.app.task.taskUtils.baseAction
{
   import com.robot.core.CommandID;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class SetTaskBuf
   {
      
      private static var _buf:String;
      
      private static var _taskId:uint;
      
      public static const SET_BUF_OK:String = "set_buf_ok";
      
      public function SetTaskBuf()
      {
         super();
      }
      
      public static function setBuf() : void
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeUTFBytes(_buf);
         _loc1_.length = 20;
         SocketConnection.addCmdListener(CommandID.ADD_TASK_BUF,onAddBuf);
         SocketConnection.send(CommandID.ADD_TASK_BUF,_taskId,_loc1_);
      }
      
      private static function onAddBuf(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.ADD_TASK_BUF,onAddBuf);
         EventManager.dispatchEvent(new Event(SET_BUF_OK));
      }
      
      public static function set taskId(param1:uint) : void
      {
         _taskId = param1;
      }
      
      public static function set buf(param1:String) : void
      {
         _buf = param1;
      }
      
      public static function get bufValue() : String
      {
         return _buf;
      }
   }
}

