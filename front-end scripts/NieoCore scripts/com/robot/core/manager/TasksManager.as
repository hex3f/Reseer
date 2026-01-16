package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.TaskEvent;
   import com.robot.core.info.task.TaskBufInfo;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.task.TaskInfo;
   import com.robot.core.manager.task.TaskType;
   import com.robot.core.net.SocketLoader;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.Utils;
   
   public class TasksManager
   {
      
      private static var _instance:EventDispatcher;
      
      public static const PATH:String = "com.robot.app.task.tc.TaskClass_";
      
      public static const UN_ACCEPT:uint = 0;
      
      public static const ALR_ACCEPT:uint = 1;
      
      public static const COMPLETE:uint = 3;
      
      public static var taskList:Array = [];
      
      private static var bShowPanel:Boolean = false;
      
      public function TasksManager()
      {
         super();
      }
      
      public static function isParentAccept(param1:uint, param2:Function) : void
      {
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:Array = TasksXMLInfo.getParent(param1);
         var _loc6_:int = int(_loc5_.length);
         if(_loc6_ == 0)
         {
            param2(true);
            return;
         }
         if(TasksXMLInfo.isMat(param1))
         {
            for each(_loc3_ in _loc5_)
            {
               switch(getTaskStatus(_loc3_))
               {
                  case UN_ACCEPT:
                  case ALR_ACCEPT:
                     param2(false);
                     return;
               }
            }
            param2(true);
            return;
         }
         for each(_loc4_ in _loc5_)
         {
            if(getTaskStatus(_loc4_) == 3)
            {
               param2(true);
               return;
            }
         }
         param2(false);
      }
      
      private static function getTypeCmd(param1:uint, param2:Array) : uint
      {
         var _loc3_:uint = TasksXMLInfo.getType(param1);
         if(_loc3_ == TaskType.NORMAL)
         {
            return param2[0];
         }
         if(_loc3_ == TaskType.DAILY)
         {
            return param2[1];
         }
         throw new TypeError("任务ID为：" + param1.toString() + " 的任务类型不正确");
      }
      
      public static function accept(param1:uint, param2:Function = null) : void
      {
         var id:uint = param1;
         var event:Function = param2;
         switch(getTaskStatus(id))
         {
            case UN_ACCEPT:
               isParentAccept(id,function(param1:Boolean):void
               {
                  var _loc2_:* = 0;
                  var _loc3_:SocketLoader = null;
                  if(param1)
                  {
                     _loc2_ = getTypeCmd(id,[CommandID.ACCEPT_TASK,CommandID.ACCEPT_DAILY_TASK]);
                     _loc3_ = new SocketLoader(_loc2_);
                     _loc3_.extData = new TaskInfo(id,0,event);
                     _loc3_.addEventListener(SocketEvent.COMPLETE,onAcceptServer);
                     _loc3_.load(id);
                     return;
                  }
                  if(event != null)
                  {
                     event(false);
                  }
                  dispatchEvent(TaskEvent.ACCEPT,id,0,false);
               });
               return;
            case ALR_ACCEPT:
            case COMPLETE:
               if(event != null)
               {
                  event(false);
               }
               dispatchEvent(TaskEvent.ACCEPT,id,0,false);
               return;
            default:
               return;
         }
      }
      
      private static function onAcceptServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onAcceptServer);
         _loc2_.destroy();
         setTaskStatus(_loc3_.id,ALR_ACCEPT);
         if(_loc3_.callback != null)
         {
            _loc3_.callback(true);
         }
         dispatchEvent(TaskEvent.ACCEPT,_loc3_.id,_loc3_.pro,true);
      }
      
      public static function complete(param1:uint, param2:uint, param3:Function = null, param4:Boolean = false, param5:uint = 1) : void
      {
         var id:uint = param1;
         var pro:uint = param2;
         var event:Function = param3;
         var bShowpanel:Boolean = param4;
         var outType:uint = param5;
         var proLen:int = 0;
         var cmd:uint = 0;
         var sl:SocketLoader = null;
         var tInfo:TaskInfo = null;
         bShowPanel = bShowpanel;
         if(TasksXMLInfo.isDir(id))
         {
            isParentAccept(id,function(param1:Boolean):void
            {
               if(param1)
               {
                  sendCompleteTask(id,pro,outType,event);
                  return;
               }
               if(event != null)
               {
                  event(false);
               }
               dispatchEvent(TaskEvent.COMPLETE,id,pro,false);
            });
            return;
         }
         switch(getTaskStatus(id))
         {
            case UN_ACCEPT:
               if(event != null)
               {
                  event(false);
               }
               dispatchEvent(TaskEvent.COMPLETE,id,pro,false);
               return;
            case ALR_ACCEPT:
               proLen = TasksXMLInfo.getTaskPorCount(id);
               if(proLen <= 1)
               {
                  sendCompleteTask(id,pro,outType,event);
                  return;
               }
               if(pro >= proLen)
               {
                  pro = uint(proLen - 1);
               }
               cmd = getTypeCmd(id,[CommandID.GET_TASK_BUF,CommandID.GET_DAILY_TASK_BUF]);
               sl = new SocketLoader(cmd);
               tInfo = new TaskInfo(id,pro,event);
               tInfo.outType = outType;
               sl.extData = tInfo;
               sl.addEventListener(SocketEvent.COMPLETE,onGetCompServer);
               sl.load(id);
               return;
               break;
            case COMPLETE:
               if(event != null)
               {
                  event(false);
               }
               dispatchEvent(TaskEvent.COMPLETE,id,pro,false);
               return;
            default:
               return;
         }
      }
      
      private static function onGetCompServer(param1:SocketEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         var _loc5_:SocketLoader = param1.target as SocketLoader;
         var _loc6_:TaskInfo = _loc5_.extData as TaskInfo;
         var _loc7_:uint = _loc6_.id;
         var _loc8_:uint = _loc6_.pro;
         var _loc9_:uint = _loc6_.outType;
         _loc5_.removeEventListener(SocketEvent.COMPLETE,onGetCompServer);
         _loc5_.destroy();
         var _loc10_:TaskBufInfo = param1.data as TaskBufInfo;
         var _loc11_:uint = _loc8_;
         _loc10_.buf.position = _loc8_;
         if(_loc10_.buf.readBoolean())
         {
            if(_loc6_.callback != null)
            {
               _loc6_.callback(false);
            }
            dispatchEvent(TaskEvent.COMPLETE,_loc10_.taskId,_loc8_,false);
            return;
         }
         var _loc12_:int = TasksXMLInfo.getTaskPorCount(_loc7_);
         var _loc13_:Boolean = true;
         var _loc14_:int = 0;
         while(_loc14_ < _loc12_)
         {
            if(_loc14_ != _loc8_)
            {
               _loc10_.buf.position = _loc14_;
               if(!_loc10_.buf.readBoolean())
               {
                  _loc13_ = false;
                  break;
               }
            }
            _loc14_++;
         }
         if(TasksXMLInfo.isEnd(_loc7_))
         {
            if(_loc11_ == _loc12_ - 1)
            {
               _loc13_ = true;
            }
         }
         if(_loc13_)
         {
            sendCompleteTask(_loc7_,_loc8_,_loc9_,_loc6_.callback);
            return;
         }
         var _loc15_:Boolean = true;
         var _loc16_:Array = TasksXMLInfo.getProParent(_loc7_,_loc8_);
         var _loc17_:int = int(_loc16_.length);
         if(_loc17_ == 0)
         {
            if(!TasksXMLInfo.isProMat(_loc7_,_loc8_))
            {
               sendCompletePro(_loc7_,_loc8_,_loc10_.buf,_loc6_.callback);
               return;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc8_)
            {
               _loc10_.buf.position = _loc2_;
               if(!_loc10_.buf.readBoolean())
               {
                  _loc15_ = false;
                  break;
               }
               _loc2_++;
            }
         }
         else if(TasksXMLInfo.isProMat(_loc7_,_loc8_))
         {
            for each(_loc3_ in _loc16_)
            {
               _loc10_.buf.position = _loc3_;
               if(!_loc10_.buf.readBoolean())
               {
                  _loc15_ = false;
                  break;
               }
            }
         }
         else
         {
            _loc15_ = false;
            for each(_loc4_ in _loc16_)
            {
               _loc10_.buf.position = _loc4_;
               if(_loc10_.buf.readBoolean())
               {
                  _loc15_ = true;
                  break;
               }
            }
         }
         if(_loc15_)
         {
            sendCompletePro(_loc7_,_loc8_,_loc10_.buf,_loc6_.callback);
         }
         else
         {
            if(_loc6_.callback != null)
            {
               _loc6_.callback(false);
            }
            dispatchEvent(TaskEvent.COMPLETE,_loc7_,_loc8_,false);
         }
      }
      
      public static function quit(param1:uint, param2:Function = null) : void
      {
         var _loc3_:* = 0;
         var _loc4_:SocketLoader = null;
         if(getTaskStatus(param1) == 1)
         {
            _loc3_ = getTypeCmd(param1,[CommandID.DELETE_TASK,CommandID.DELETE_DAILY_TASK]);
            _loc4_ = new SocketLoader(_loc3_);
            _loc4_.extData = new TaskInfo(param1,0,param2);
            _loc4_.addEventListener(SocketEvent.COMPLETE,onQuitServer);
            _loc4_.load(param1);
            return;
         }
         if(param2 != null)
         {
            param2(false);
         }
         dispatchEvent(TaskEvent.QUIT,param1,0,false);
      }
      
      private static function onQuitServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onQuitServer);
         _loc2_.destroy();
         setTaskStatus(_loc3_.id,UN_ACCEPT);
         if(_loc3_.callback != null)
         {
            _loc3_.callback(true);
         }
         dispatchEvent(TaskEvent.QUIT,_loc3_.id,_loc3_.pro,true);
      }
      
      public static function getTaskStatus(param1:uint) : uint
      {
         if(param1 < 1)
         {
            param1 = 1;
         }
         return taskList[param1 - 1];
      }
      
      public static function setTaskStatus(param1:uint, param2:uint) : void
      {
         taskList[param1 - 1] = param2;
      }
      
      public static function getProStatus(param1:uint, param2:uint, param3:Function = null) : void
      {
         var _loc4_:uint = getTaskStatus(param1);
         if(_loc4_ == UN_ACCEPT || _loc4_ == COMPLETE)
         {
            if(param3 != null)
            {
               param3(false);
            }
            dispatchEvent(TaskEvent.GET_PRO_STATUS,param1,param2,false);
            return;
         }
         var _loc5_:uint = getTypeCmd(param1,[CommandID.GET_TASK_BUF,CommandID.GET_DAILY_TASK_BUF]);
         var _loc6_:SocketLoader = new SocketLoader(_loc5_);
         _loc6_.extData = new TaskInfo(param1,param2,param3);
         _loc6_.addEventListener(SocketEvent.COMPLETE,onGetProServer);
         _loc6_.load(param1);
      }
      
      private static function onGetProServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onGetProServer);
         _loc2_.destroy();
         var _loc4_:TaskBufInfo = param1.data as TaskBufInfo;
         _loc4_.buf.position = _loc3_.pro;
         var _loc5_:Boolean = _loc4_.buf.readBoolean();
         if(_loc3_.callback != null)
         {
            _loc3_.callback(_loc5_);
         }
         dispatchEvent(TaskEvent.GET_PRO_STATUS,_loc3_.id,_loc3_.pro,_loc5_);
      }
      
      public static function setProStatus(param1:uint, param2:uint, param3:Boolean, param4:Function = null) : void
      {
         var _loc5_:uint = getTaskStatus(param1);
         if(_loc5_ == UN_ACCEPT)
         {
            if(param4 != null)
            {
               param4(false);
            }
            dispatchEvent(TaskEvent.SET_PRO_STATUS,param1,param2,false);
            return;
         }
         var _loc6_:uint = getTypeCmd(param1,[CommandID.GET_TASK_BUF,CommandID.GET_DAILY_TASK_BUF]);
         var _loc7_:SocketLoader = new SocketLoader(_loc6_);
         var _loc8_:TaskInfo = new TaskInfo(param1,param2,param4);
         _loc8_.status = param3;
         _loc7_.extData = _loc8_;
         _loc7_.addEventListener(SocketEvent.COMPLETE,onSetProServer);
         _loc7_.load(param1);
      }
      
      private static function onSetProServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onSetProServer);
         _loc2_.destroy();
         var _loc4_:TaskBufInfo = param1.data as TaskBufInfo;
         sendCompletePro(_loc3_.id,_loc3_.pro,_loc4_.buf,_loc3_.callback,_loc3_.status,false);
      }
      
      public static function getProStatusList(param1:uint, param2:Function = null) : void
      {
         var _loc3_:uint = getTaskStatus(param1);
         if(_loc3_ == UN_ACCEPT)
         {
            if(param2 != null)
            {
               param2([]);
            }
            dispatchEvent(TaskEvent.GET_PRO_STATUS_LIST,param1,0,false);
            return;
         }
         var _loc4_:uint = getTypeCmd(param1,[CommandID.GET_TASK_BUF,CommandID.GET_DAILY_TASK_BUF]);
         var _loc5_:SocketLoader = new SocketLoader(_loc4_);
         _loc5_.extData = new TaskInfo(param1,0,param2);
         _loc5_.addEventListener(SocketEvent.COMPLETE,onGetProListServer);
         _loc5_.load(param1);
      }
      
      private static function onGetProListServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onGetProListServer);
         _loc2_.destroy();
         var _loc4_:TaskBufInfo = param1.data as TaskBufInfo;
         var _loc5_:Array = [];
         var _loc6_:int = TasksXMLInfo.getTaskPorCount(_loc4_.taskId);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc4_.buf.position = _loc7_;
            _loc5_[_loc7_] = _loc4_.buf.readBoolean();
            _loc7_++;
         }
         if(_loc3_.callback != null)
         {
            _loc3_.callback(_loc5_);
         }
         dispatchEvent(TaskEvent.GET_PRO_STATUS_LIST,_loc3_.id,_loc3_.pro,true,_loc5_);
      }
      
      private static function sendCompleteTask(param1:uint, param2:uint, param3:uint, param4:Function) : void
      {
         var _loc5_:uint = getTypeCmd(param1,[CommandID.COMPLETE_TASK,CommandID.COMPLETE_DAILY_TASK]);
         var _loc6_:SocketLoader = new SocketLoader(_loc5_);
         var _loc7_:TaskInfo = new TaskInfo(param1,param2,param4);
         _loc7_.outType = param3;
         _loc6_.extData = _loc7_;
         _loc6_.addEventListener(SocketEvent.COMPLETE,onCompleteTaskServer);
         _loc6_.load(param1,param3);
      }
      
      private static function onCompleteTaskServer(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = param1.target as SocketLoader;
         var _loc3_:TaskInfo = _loc2_.extData as TaskInfo;
         _loc2_.removeEventListener(SocketEvent.COMPLETE,onCompleteTaskServer);
         _loc2_.destroy();
         var _loc4_:NoviceFinishInfo = param1.data as NoviceFinishInfo;
         setTaskStatus(_loc4_.taskID,COMPLETE);
         if(_loc3_.callback != null)
         {
            _loc3_.callback(true);
         }
         dispatchEvent(TaskEvent.COMPLETE,_loc3_.id,_loc3_.pro,true);
      }
      
      private static function sendCompletePro(param1:uint, param2:uint, param3:ByteArray, param4:Function = null, param5:Boolean = true, param6:Boolean = true) : void
      {
         param3.position = param2;
         param3.writeBoolean(param5);
         var _loc7_:uint = getTypeCmd(param1,[CommandID.ADD_TASK_BUF,CommandID.ADD_DAILY_TASK_BUF]);
         var _loc8_:SocketLoader = new SocketLoader(_loc7_);
         var _loc9_:TaskInfo = new TaskInfo(param1,param2,param4);
         _loc9_.status = param5;
         _loc9_.isComplete = param6;
         _loc8_.extData = _loc9_;
         _loc8_.addEventListener(SocketEvent.COMPLETE,onCompleteProServer);
         _loc8_.load(param1,param3);
      }
      
      private static function onCompleteProServer(param1:SocketEvent) : void
      {
         var e:SocketEvent = param1;
         var cla:Class = null;
         var p:String = null;
         var cl:Object = null;
         var sl:SocketLoader = e.target as SocketLoader;
         var tInfo:TaskInfo = sl.extData as TaskInfo;
         sl.removeEventListener(SocketEvent.COMPLETE,onCompleteProServer);
         sl.destroy();
         if(tInfo.callback != null)
         {
            tInfo.callback(true);
         }
         if(tInfo.isComplete)
         {
            dispatchEvent(TaskEvent.COMPLETE,tInfo.id,tInfo.pro,true);
            cla = Utils.getClass(PATH + tInfo.id.toString() + "_" + tInfo.pro.toString());
            if(Boolean(cla))
            {
               new cla();
            }
         }
         else
         {
            dispatchEvent(TaskEvent.SET_PRO_STATUS,tInfo.id,tInfo.pro,true);
         }
         if(bShowPanel)
         {
            try
            {
               p = "com.robot.app.task.control.TaskController_" + tInfo.id;
               cl = getDefinitionByName(p) as Class;
               cl.showPanel();
               bShowPanel = false;
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function isComNoviceTask() : Boolean
      {
         var _loc1_:Boolean = false;
         if(MainManager.checkIsNovice())
         {
            if(TasksManager.getTaskStatus(88) == TasksManager.COMPLETE)
            {
               _loc1_ = true;
            }
         }
         else if(TasksManager.getTaskStatus(4) == TasksManager.COMPLETE)
         {
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
      }
      
      public static function addListener(param1:String, param2:uint, param3:uint, param4:Function) : void
      {
         if(getTaskStatus(param2) == COMPLETE)
         {
            return;
         }
         getInstance().addEventListener(param1 + "_" + param2.toString() + "_" + param3.toString(),param4);
      }
      
      public static function removeListener(param1:String, param2:uint, param3:uint, param4:Function) : void
      {
         getInstance().removeEventListener(param1 + "_" + param2.toString() + "_" + param3.toString(),param4);
      }
      
      public static function dispatchEvent(param1:String, param2:uint, param3:uint, param4:Boolean, param5:Array = null) : void
      {
         if(hasListener(param1,param2,param3))
         {
            getInstance().dispatchEvent(new TaskEvent(param1,param2,param3,param4,param5));
         }
      }
      
      public static function hasListener(param1:String, param2:uint, param3:uint) : Boolean
      {
         return getInstance().hasEventListener(param1 + "_" + param2.toString() + "_" + param3.toString());
      }
   }
}

