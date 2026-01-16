package com.robot.core.info.task
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   
   public class TaskBufInfo
   {
      
      private var _taskId:uint;
      
      private var _flag:uint;
      
      private var _buf:ByteArray = new ByteArray();
      
      public function TaskBufInfo(param1:IDataInput)
      {
         super();
         this._taskId = param1.readUnsignedInt();
         this._flag = param1.readUnsignedInt();
         param1.readBytes(this._buf);
      }
      
      public function get taskId() : uint
      {
         return this._taskId;
      }
      
      public function get flag() : uint
      {
         return this._flag;
      }
      
      public function get buf() : ByteArray
      {
         return this._buf;
      }
   }
}

