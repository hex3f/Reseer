package com.robot.core.info
{
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.mode.NpcModel;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.ds.HashMap;
   
   [Event(name="showYellowQuestion",type="com.robot.core.taskSys.TaskInfo")]
   [Event(name="showBlueQuestion",type="com.robot.core.taskSys.TaskInfo")]
   [Event(name="showYellowExcal",type="com.robot.core.taskSys.TaskInfo")]
   public class NpcTaskInfo extends EventDispatcher
   {
      
      public static const SHOW_YELLOW_QUESTION:String = "showYellowQuestion";
      
      public static const SHOW_BLUE_QUESTION:String = "showBlueQuestion";
      
      public static const SHOW_YELLOW_EXCAL:String = "showYellowExcal";
      
      private var tasks:Array = [];
      
      private var _acceptList:Array = [];
      
      private var endIDs:Array = [];
      
      private var proIDs:Array = [];
      
      private var canCompleteIDs:Array = [];
      
      private var model:NpcModel;
      
      private var alAcceptIDs:Array = [];
      
      private var alAcceptIndex:uint;
      
      private var _isRelate:Boolean;
      
      private var _relateIDs:HashMap = new HashMap();
      
      private var queueNum:uint = 0;
      
      private var isQueue:Boolean = false;
      
      public function NpcTaskInfo(param1:Array, param2:Array, param3:Array, param4:NpcModel)
      {
         super();
         this.model = param4;
         this.tasks = param1.slice();
         this.endIDs = param2.slice();
         this.proIDs = param3.slice();
         this.alAcceptIndex = 0;
         this.canCompleteIDs = [];
      }
      
      public function refresh() : void
      {
         ++this.queueNum;
         this.checkQueue();
      }
      
      private function checkQueue() : void
      {
         if(this.queueNum > 0 && !this.isQueue)
         {
            this.isQueue = true;
            --this.queueNum;
            this.alAcceptIndex = 0;
            this.canCompleteIDs = [];
            this._acceptList = [];
            this.alAcceptIDs = [];
            this._relateIDs = new HashMap();
            this.checkTaskStatus();
         }
      }
      
      public function destroy() : void
      {
         this.model = null;
      }
      
      public function checkTaskStatus() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         this.initAcceptList();
         this._isRelate = false;
         if(this.proIDs.indexOf(0) != -1 && TasksManager.getTaskStatus(4) != TasksManager.COMPLETE)
         {
            this._relateIDs.add(4,4);
            this._isRelate = true;
         }
         else
         {
            _loc1_ = 1;
            while(_loc1_ < TasksManager.taskList.length + 1)
            {
               if(TasksManager.getTaskStatus(_loc1_) == TasksManager.ALR_ACCEPT)
               {
                  _loc2_ = int(this.proIDs.indexOf(_loc1_));
                  if(_loc2_ != -1 || _loc1_ <= 4)
                  {
                     this._relateIDs.add(_loc1_,_loc1_);
                     this._isRelate = true;
                  }
               }
               _loc1_++;
            }
         }
         for each(_loc1_ in this.tasks)
         {
            if(TasksManager.getTaskStatus(_loc1_) == TasksManager.COMPLETE)
            {
               _loc2_ = int(this.tasks.indexOf(_loc1_));
               if(_loc2_ != -1)
               {
                  this.tasks.splice(_loc2_,1);
               }
            }
         }
         for each(_loc1_ in this.endIDs)
         {
            if(TasksManager.getTaskStatus(_loc1_) == TasksManager.ALR_ACCEPT)
            {
               this.alAcceptIDs.push(_loc1_);
            }
         }
         if(this.alAcceptIDs.length > 0)
         {
            this.checkAlrAcceptProStatus();
         }
         else
         {
            if(this._acceptList.length > 0)
            {
               this.showYellowExcalMark();
            }
            this.isQueue = false;
            this.checkQueue();
         }
      }
      
      private function checkAlrAcceptProStatus() : void
      {
         if(this.alAcceptIndex == this.alAcceptIDs.length)
         {
            this.onCheckAlrAcceptTask();
            this.isQueue = false;
            this.checkQueue();
            return;
         }
         var _loc1_:uint = uint(this.alAcceptIDs[this.alAcceptIndex]);
         TasksManager.getProStatusList(_loc1_,this.onGetBuff);
      }
      
      private function onGetBuff(param1:Array) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:uint = uint(this.alAcceptIDs[this.alAcceptIndex]);
         param1.pop();
         var _loc4_:Boolean = true;
         for each(_loc2_ in param1)
         {
            if(_loc2_ == false)
            {
               _loc4_ = false;
               break;
            }
         }
         if(_loc4_ && _loc3_ != 25)
         {
            this.canCompleteIDs.push(_loc3_);
         }
         ++this.alAcceptIndex;
         this.checkAlrAcceptProStatus();
      }
      
      private function onCheckAlrAcceptTask() : void
      {
         if(this.canCompleteIDs.length > 0)
         {
            this.showYellowQuestionMark();
         }
         else
         {
            this.showBlueQuestionMark();
         }
      }
      
      private function initAcceptList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = 0;
         var _loc3_:Array = null;
         var _loc4_:Boolean = false;
         var _loc5_:Number = 0;
         this._acceptList = [];
         for each(_loc2_ in this.tasks)
         {
            if(TasksManager.getTaskStatus(_loc2_) != TasksManager.COMPLETE)
            {
               _loc3_ = TasksXMLInfo.getParent(_loc2_);
               _loc4_ = true;
               for each(_loc5_ in _loc3_)
               {
                  if(TasksManager.getTaskStatus(_loc5_) != TasksManager.COMPLETE)
                  {
                     _loc4_ = false;
                     break;
                  }
               }
               if(_loc4_)
               {
                  this._acceptList.push(_loc2_);
               }
            }
         }
      }
      
      private function getNpcIndex(param1:uint) : uint
      {
         var _loc2_:Number = 0;
         switch(param1)
         {
            case 1:
               _loc2_ = 0;
               break;
            case 2:
               _loc2_ = 5;
               break;
            case 3:
               _loc2_ = 2;
               break;
            case 4:
               _loc2_ = 6;
               break;
            case 5:
               _loc2_ = 1;
               break;
            case 6:
               _loc2_ = 4;
               break;
            case 8:
               _loc2_ = 7;
               break;
            case 10:
               _loc2_ = 3;
               break;
            default:
               _loc2_ = 9;
         }
         return _loc2_;
      }
      
      private function showYellowExcalMark() : void
      {
         if(!this.isQueue || this.queueNum == 0)
         {
            dispatchEvent(new Event(SHOW_YELLOW_EXCAL));
         }
      }
      
      private function showYellowQuestionMark() : void
      {
         if(!this.isQueue || this.queueNum == 0)
         {
            dispatchEvent(new Event(SHOW_YELLOW_QUESTION));
         }
      }
      
      private function showBlueQuestionMark() : void
      {
         if(!this.isQueue || this.queueNum == 0)
         {
            dispatchEvent(new Event(SHOW_BLUE_QUESTION));
         }
      }
      
      public function get taskIDList() : Array
      {
         return this.tasks;
      }
      
      public function get acceptList() : Array
      {
         var _loc1_:Number = 0;
         var _loc2_:Array = this._acceptList.slice();
         for each(_loc1_ in this.proIDs)
         {
            if(TasksManager.getTaskStatus(_loc1_) == TasksManager.ALR_ACCEPT)
            {
               if(_loc1_ == 1 || _loc1_ == 2 || _loc1_ == 3 || _loc1_ == 4)
               {
                  _loc1_ = 4;
               }
               if(_loc2_.indexOf(_loc1_) == -1)
               {
                  _loc2_.push(_loc1_);
               }
            }
         }
         return _loc2_;
      }
      
      public function get proList() : Array
      {
         return this.proIDs;
      }
      
      public function get completeList() : Array
      {
         return this.canCompleteIDs;
      }
      
      public function get alreadAcceptList() : Array
      {
         return this.alAcceptIDs;
      }
      
      public function get isRelateTask() : Boolean
      {
         return this._isRelate;
      }
      
      public function get relateIDs() : HashMap
      {
         return this._relateIDs;
      }
   }
}

