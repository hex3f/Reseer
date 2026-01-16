package com.robot.core.manager.task
{
   public class TaskInfo
   {
      
      public var id:uint;
      
      public var pro:uint;
      
      public var callback:Function;
      
      public var outType:uint;
      
      public var status:Boolean;
      
      public var isComplete:Boolean;
      
      public var type:uint;
      
      public function TaskInfo(param1:uint, param2:uint, param3:Function)
      {
         super();
         this.id = param1;
         this.pro = param2;
         this.callback = param3;
      }
   }
}

