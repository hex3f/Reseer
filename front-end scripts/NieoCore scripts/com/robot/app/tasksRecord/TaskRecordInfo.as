package com.robot.app.tasksRecord
{
   public class TaskRecordInfo
   {
      
      private var _taskId:uint;
      
      private var _isVip:Boolean;
      
      private var _newOnline:Boolean;
      
      private var _mapId:uint;
      
      private var _npc:String;
      
      private var _tip:String;
      
      private var _startDes:String;
      
      private var _stopDes:String;
      
      private var _output:Array;
      
      private var _name:String;
      
      private var _onLineData:Number;
      
      private var _type:uint;
      
      private var _offLine:Boolean;
      
      public function TaskRecordInfo(param1:uint)
      {
         super();
         this._taskId = param1;
         this._isVip = TasksRecordConfig.getIsVip(this._taskId);
         this._type = TasksRecordConfig.getTaskType(this._taskId);
         this._offLine = TasksRecordConfig.getTaskOffLineForId(this._taskId);
         this._name = TasksRecordConfig.getName(this._taskId);
         this._onLineData = TasksRecordConfig.getOnlineData(this._taskId);
         this._newOnline = TasksRecordConfig.getTaskNewOnlineForId(this._taskId);
         this._mapId = TasksRecordConfig.getAltTaskMapId(this._taskId);
         this._npc = TasksRecordConfig.getTaskNpcForId(this._taskId);
         this._tip = TasksRecordConfig.getTaskNpcTips(this._taskId);
         this._startDes = TasksRecordConfig.getTaskStartDes(this._taskId);
         this._stopDes = TasksRecordConfig.getTaskStopDes(this._taskId);
         this._output = TasksRecordConfig.getTaskReward(this._taskId);
      }
      
      public function get offLine() : Boolean
      {
         return this._offLine;
      }
      
      public function get type() : uint
      {
         return this._type;
      }
      
      public function get isVip() : Boolean
      {
         return this._isVip;
      }
      
      public function get onlineData() : Number
      {
         return this._onLineData;
      }
      
      public function get taskId() : uint
      {
         return this._taskId;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get newOnline() : Boolean
      {
         return this._newOnline;
      }
      
      public function get mapId() : uint
      {
         return this._mapId;
      }
      
      public function get npc() : String
      {
         return this._npc;
      }
      
      public function get tip() : String
      {
         return this._tip;
      }
      
      public function get startDes() : String
      {
         return this._startDes;
      }
      
      public function get stopDes() : String
      {
         return this._stopDes;
      }
      
      public function get output() : Array
      {
         return this._output;
      }
   }
}

