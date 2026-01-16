package com.robot.app.task.taskProStep
{
   public class TaskStepInfo
   {
      
      public var taskID:uint;
      
      public var pro:uint;
      
      public var stepID:uint = 0;
      
      public var mapID:uint = 0;
      
      public var stepType:uint = 0;
      
      public var goto1:Array = [];
      
      public var isComplete:Boolean = false;
      
      public function TaskStepInfo(param1:uint, param2:uint, param3:uint, param4:XML = null)
      {
         super();
         this.taskID = param1;
         this.pro = param2;
         this.mapID = param3;
         if(Boolean(param4))
         {
            this.stepID = param4.@id;
            this.stepType = param4.@type;
            this.goto1 = String(param4["@goto"]).split("_");
         }
      }
   }
}

