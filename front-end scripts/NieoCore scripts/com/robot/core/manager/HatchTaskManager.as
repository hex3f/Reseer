package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.HatchTaskXMLInfo;
   import com.robot.core.info.HatchTask.HatchTaskBufInfo;
   import com.robot.core.manager.HatchTask.HatchTaskInfo;
   import com.robot.core.net.SocketConnection;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   public class HatchTaskManager
   {
      
      private static var _instance:EventDispatcher;
      
      private static var _beadMap:HashMap = new HashMap();
      
      private static var _taskMap:HashMap = new HashMap();
      
      private static var b:Boolean = true;
      
      public function HatchTaskManager()
      {
         super();
      }
      
      public static function getTaskStatusList(param1:Function) : void
      {
         var ts:Array = null;
         var func:Function = param1;
         ts = null;
         getSoulBeadList(function(param1:Array):void
         {
            var arr:Array = param1;
            var upLoop:Function = function(param1:int):void
            {
               var catchTime:uint = 0;
               var i:int = param1;
               if(i == ts.length)
               {
                  if(func != null)
                  {
                     func(_beadMap);
                  }
                  ts = null;
                  b = true;
                  return;
               }
               catchTime = uint(ts[i][0]);
               SocketConnection.addCmdListener(CommandID.GET_SOUL_BEAD_BUF,function(param1:SocketEvent):void
               {
                  var _loc3_:Number = 0;
                  var _loc4_:Boolean = false;
                  SocketConnection.removeCmdListener(CommandID.GET_SOUL_BEAD_BUF,arguments.callee);
                  var _loc5_:HatchTaskBufInfo = param1.data as HatchTaskBufInfo;
                  var _loc6_:uint = _loc5_.obtainTm;
                  var _loc7_:ByteArray = _loc5_.buf;
                  var _loc8_:Array = [];
                  while(_loc3_ < 20)
                  {
                     _loc4_ = Boolean(_loc7_.readBoolean());
                     _loc8_.push(_loc4_);
                     _loc3_++;
                  }
                  var _loc9_:HatchTaskInfo = new HatchTaskInfo(_loc6_,ts[i][1],_loc8_,func);
                  var _loc10_:uint = uint(HatchTaskXMLInfo.getTaskProCount(ts[i][1]));
                  var _loc11_:Number = 0;
                  var _loc12_:Number = 0;
                  while(_loc12_ < _loc10_)
                  {
                     if(_loc8_[_loc12_] == true)
                     {
                        _loc11_++;
                     }
                     _loc12_++;
                  }
                  if(_loc11_ == _loc10_)
                  {
                     _loc9_.isComplete = true;
                  }
                  _beadMap.add(_loc6_,_loc9_);
                  ++i;
                  upLoop(i);
               });
               SocketConnection.send(CommandID.GET_SOUL_BEAD_BUF,catchTime);
            };
            if(!b)
            {
               return;
            }
            b = false;
            ts = arr;
            if(ts == null)
            {
               return;
            }
            upLoop(0);
         });
      }
      
      public static function getSoulBeadList(param1:Function) : void
      {
         var arr:Array = null;
         var func:Function = param1;
         arr = null;
         arr = [];
         SocketConnection.addCmdListener(CommandID.GET_SOUL_BEAD_List,function(param1:SocketEvent):void
         {
            var _loc3_:* = 0;
            var _loc4_:* = 0;
            SocketConnection.removeCmdListener(CommandID.GET_SOUL_BEAD_List,arguments.callee);
            var _loc5_:ByteArray = param1.data as ByteArray;
            var _loc6_:uint = _loc5_.readUnsignedInt();
            var _loc7_:Number = 0;
            while(_loc7_ < _loc6_)
            {
               _loc3_ = _loc5_.readUnsignedInt();
               _loc4_ = _loc5_.readUnsignedInt();
               arr.push([_loc3_,_loc4_]);
               _loc7_++;
            }
            func(arr);
         });
         SocketConnection.send(CommandID.GET_SOUL_BEAD_List);
      }
      
      public static function complete(param1:uint, param2:uint, param3:uint, param4:Function = null) : void
      {
         var arr:Array = null;
         var info:HatchTaskInfo = null;
         var obtainTm:uint = param1;
         var id:uint = param2;
         var pro:uint = param3;
         var event:Function = param4;
         arr = null;
         info = null;
         var proCnt:uint = 0;
         var i:uint = 0;
         var hi:HatchTaskInfo = _beadMap.getValue(obtainTm);
         arr = hi.statusList;
         info = new HatchTaskInfo(obtainTm,id,arr,event);
         if(HatchTaskXMLInfo.isDir(id))
         {
            proCnt = uint(HatchTaskXMLInfo.getTaskProCount(id));
            i = 0;
            while(i < proCnt)
            {
               setTaskProStatus(obtainTm,proCnt,true,function(param1:Boolean):void
               {
                  arr.push(param1);
                  info.isComplete = true;
                  _beadMap.add(obtainTm,info);
                  event(info.isComplete);
               });
               i++;
            }
         }
         else
         {
            setTaskProStatus(obtainTm,pro,true,function(param1:Boolean):void
            {
               arr[pro] = param1;
               var _loc2_:HatchTaskInfo = info;
               _beadMap.add(obtainTm,info);
               var _loc3_:uint = uint(HatchTaskXMLInfo.getTaskProCount(id));
               var _loc4_:Number = 0;
               while(_loc4_ < _loc3_)
               {
                  if(HatchTaskManager.getTaskList(obtainTm)[_loc4_] != true)
                  {
                     event(info.isComplete);
                     return;
                  }
                  _loc4_++;
               }
               info.isComplete = true;
               _beadMap.add(obtainTm,info);
               event(info.isComplete);
            });
         }
      }
      
      public static function getTaskProStatus(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:HatchTaskInfo = _beadMap.getValue(param1);
         return _loc3_.statusList[param2];
      }
      
      public static function setTaskProStatus(param1:uint, param2:uint, param3:Boolean, param4:Function = null) : void
      {
         var obtainTime:uint = param1;
         var pro:uint = param2;
         var status:Boolean = param3;
         var func:Function = param4;
         SocketConnection.addCmdListener(CommandID.GET_SOUL_BEAD_BUF,function(param1:SocketEvent):void
         {
            var info:HatchTaskBufInfo = null;
            var obtainTime:uint = 0;
            var buf:ByteArray = null;
            var sts:Boolean = false;
            var e:SocketEvent = param1;
            SocketConnection.removeCmdListener(CommandID.GET_SOUL_BEAD_BUF,arguments.callee);
            info = e.data as HatchTaskBufInfo;
            obtainTime = info.obtainTm;
            buf = info.buf;
            sts = buf.readBoolean();
            buf.position = pro;
            buf.writeBoolean(status);
            buf.length = 20;
            SocketConnection.addCmdListener(CommandID.SET_SOUL_BEAD_BUF,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.SET_SOUL_BEAD_BUF,arguments.callee);
               if(func != null)
               {
                  func(status);
               }
            });
            SocketConnection.send(CommandID.SET_SOUL_BEAD_BUF,obtainTime,buf);
         });
         SocketConnection.send(CommandID.GET_SOUL_BEAD_BUF,obtainTime);
      }
      
      public static function getProStatus(param1:uint, param2:uint, param3:Function = null) : void
      {
         var obtainTime:uint = param1;
         var pro:uint = param2;
         var func:Function = param3;
         SocketConnection.addCmdListener(CommandID.GET_SOUL_BEAD_BUF,function(param1:SocketEvent):void
         {
            var _loc3_:Boolean = false;
            SocketConnection.removeCmdListener(CommandID.GET_SOUL_BEAD_BUF,arguments.callee);
            var _loc4_:HatchTaskBufInfo = param1.data as HatchTaskBufInfo;
            var _loc5_:uint = _loc4_.obtainTm;
            var _loc6_:ByteArray = _loc4_.buf;
            _loc6_.position = pro;
            _loc3_ = _loc6_.readBoolean();
            if(func != null)
            {
               func(_loc3_);
            }
         });
         SocketConnection.send(CommandID.GET_SOUL_BEAD_BUF,obtainTime);
      }
      
      public static function get beadMap() : HashMap
      {
         return _beadMap;
      }
      
      public static function addHeadStatus(param1:uint, param2:HatchTaskInfo) : void
      {
         _beadMap.add(param1,param2);
         HatchTaskMapManager.getSoulBeadStatusMap(_beadMap);
      }
      
      public static function removeHeadStatus(param1:uint) : void
      {
         _beadMap.remove(param1);
         HatchTaskMapManager.getSoulBeadStatusMap(_beadMap);
      }
      
      public static function getTaskList(param1:uint) : Array
      {
         var _loc2_:HatchTaskInfo = _beadMap.getValue(param1);
         return _loc2_.statusList;
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
         getInstance().addEventListener(param1 + "_" + param2.toString() + "_" + param3.toString(),param4);
      }
      
      public static function removeListener(param1:String, param2:uint, param3:uint, param4:Function) : void
      {
         getInstance().removeEventListener(param1 + "_" + param2.toString() + "_" + param3.toString(),param4);
      }
      
      public static function dispatchEvent(param1:String, param2:uint, param3:uint, param4:Array = null) : void
      {
      }
      
      public static function hasListener(param1:String, param2:uint, param3:uint) : Boolean
      {
         return getInstance().hasEventListener(param1 + "_" + param2.toString() + "_" + param3.toString());
      }
   }
}

