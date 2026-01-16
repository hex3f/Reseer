package com.robot.core.event
{
   import com.robot.core.mode.NpcModel;
   import flash.events.Event;
   
   public class NpcEvent extends Event
   {
      
      public static const TASK_WITHOUT_DES:String = "taskWithoutDes";
      
      public static const NPC_CLICK:String = "npcClick";
      
      public static const SHOW_TASK_LIST:String = "showTaskList";
      
      public static const COMPLETE_TASK:String = "completeTask";
      
      private var _model:NpcModel;
      
      private var _taskID:uint;
      
      public function NpcEvent(param1:String, param2:NpcModel, param3:uint = 0, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this._model = param2;
         this._taskID = param3;
      }
      
      public function get model() : NpcModel
      {
         return this._model;
      }
      
      public function get taskID() : uint
      {
         return this._taskID;
      }
   }
}

