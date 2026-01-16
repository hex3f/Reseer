package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.event.RelationEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.relation.OnLineInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.SharedObject;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.ds.HashSet;
   import org.taomee.events.SocketEvent;
   
   public class RelationManager
   {
      
      private static var _friendList:HashMap;
      
      private static var _blackList:HashMap;
      
      private static var _friendOnLineLength:uint;
      
      private static var _so:SharedObject;
      
      private static var _relSO:SharedObject;
      
      private static var _soFriendTimePokeSet:HashSet;
      
      private static var instance:EventDispatcher;
      
      private static const SO_FRIEND:String = "friend";
      
      private static const SO_BLACK:String = "black";
      
      private static var _allowAdd:Boolean = true;
      
      private static var _isFriendInfo:Boolean = true;
      
      private static var _isBlackInfo:Boolean = true;
      
      public function RelationManager()
      {
         super();
      }
      
      public static function setup() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_RELATION_LIST,init);
         SocketConnection.send(CommandID.GET_RELATION_LIST);
         _so = SOManager.getUser_Info();
         if(_so.data.hasOwnProperty("allowAdd"))
         {
            _allowAdd = _so.data.allowAdd;
         }
      }
      
      public static function get F_MAX() : int
      {
         if(MainManager.actorInfo == null)
         {
            return 100;
         }
         if(Boolean(MainManager.actorInfo.vip))
         {
            return 200;
         }
         return 100;
      }
      
      public static function get allowAdd() : Boolean
      {
         return _allowAdd;
      }
      
      public static function set allowAdd(param1:Boolean) : void
      {
         _allowAdd = param1;
         _so = SOManager.getUser_Info();
         _so.data.allowAdd = param1;
         SOManager.flush(_so);
      }
      
      public static function getFriendInfos(param1:Boolean = true) : Array
      {
         var prior:Boolean = param1;
         var arr:Array = _friendList.getValues();
         if(prior)
         {
            arr.forEach(function(param1:UserInfo, param2:int, param3:Array):void
            {
               param1.priorLevel = 0;
               if(Boolean(param1.vip))
               {
                  param1.priorLevel += 2;
               }
               if(param1.teacherID == MainManager.actorID)
               {
                  param1.priorLevel += 1;
               }
               if(param1.studentID == MainManager.actorID)
               {
                  param1.priorLevel += 1;
               }
               if(Boolean(param1.serverID))
               {
                  param1.priorLevel += 3;
               }
            });
            arr.sortOn("priorLevel",Array.DESCENDING | Array.NUMERIC);
         }
         return arr;
      }
      
      public static function get friendIDs() : Array
      {
         return _friendList.getKeys();
      }
      
      public static function get blackInfos() : Array
      {
         return _blackList.getValues();
      }
      
      public static function get blackIDs() : Array
      {
         return _blackList.getKeys();
      }
      
      public static function get friendLength() : int
      {
         return _friendList.length;
      }
      
      public static function get blackLength() : int
      {
         return _blackList.length;
      }
      
      public static function get friendOnLineLength() : int
      {
         return _friendOnLineLength;
      }
      
      public static function init(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GET_RELATION_LIST,init);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:UserInfo = null;
         var _loc4_:UserInfo = null;
         _friendList = new HashMap();
         var _loc5_:int = int(_loc2_.readUnsignedInt());
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = new UserInfo();
            _loc3_.userID = _loc2_.readUnsignedInt();
            _loc3_.timePoke = _loc2_.readUnsignedInt();
            _friendList.add(_loc3_.userID,_loc3_);
            _loc6_++;
         }
         _blackList = new HashMap();
         _loc5_ = int(_loc2_.readUnsignedInt());
         var _loc7_:int = 0;
         while(_loc7_ < _loc5_)
         {
            _loc4_ = new UserInfo();
            _loc4_.userID = _loc2_.readUnsignedInt();
            _blackList.add(_loc4_.userID,_loc4_);
            _loc7_++;
         }
         soInit();
      }
      
      private static function soInit() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:UserInfo = null;
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         _relSO = SOManager.getUser_Relation();
         if(_relSO.data.hasOwnProperty(SO_FRIEND))
         {
            _soFriendTimePokeSet = new HashSet();
            _loc1_ = _relSO.data[SO_FRIEND];
            _loc2_ = _friendList.getValues();
            for each(_loc3_ in _loc2_)
            {
               _loc4_ = false;
               for each(_loc5_ in _loc1_)
               {
                  if(_loc3_.userID == _loc5_.userID)
                  {
                     _loc4_ = true;
                     if(_loc3_.timePoke > _loc5_.timePoke)
                     {
                        _soFriendTimePokeSet.add(_loc3_);
                     }
                     _loc3_.hasSimpleInfo = true;
                     _loc3_.nick = _loc5_.nick;
                     _loc3_.color = _loc5_.color;
                     _loc3_.texture = _loc5_.texture;
                     _loc3_.vip = _loc5_.vip;
                     _loc3_.status = _loc5_.status;
                     _loc3_.mapID = _loc5_.mapID;
                     _loc3_.isCanBeTeacher = _loc5_.isCanBeTeacher;
                     _loc3_.teacherID = _loc5_.teacherID;
                     _loc3_.studentID = _loc5_.studentID;
                     _loc3_.graduationCount = _loc5_.graduationCount;
                     _loc3_.clothes = _loc5_.clothes.slice();
                     break;
                  }
               }
               if(!_loc4_)
               {
                  _soFriendTimePokeSet.add(_loc3_);
               }
            }
         }
      }
      
      public static function isFriend(param1:uint) : Boolean
      {
         return _friendList.containsKey(param1);
      }
      
      public static function isBlack(param1:uint) : Boolean
      {
         return _blackList.containsKey(param1);
      }
      
      public static function getFriendInfo(param1:uint) : UserInfo
      {
         return _friendList.getValue(param1) as UserInfo;
      }
      
      public static function getBlackInfo(param1:uint) : UserInfo
      {
         return _blackList.getValue(param1) as UserInfo;
      }
      
      public static function addFriend(param1:uint) : void
      {
         if(MainManager.actorID == param1)
         {
            Alarm.show("不能把自己添加为好友！");
            return;
         }
         if(friendLength >= F_MAX)
         {
            Alarm.show("好友达到上限！");
            return;
         }
         if(_friendList.containsKey(param1))
         {
            Alarm.show("好友已经存在！");
            return;
         }
         SocketConnection.send(CommandID.FRIEND_ADD,param1);
      }
      
      public static function addFriendInfo(param1:UserInfo) : void
      {
         if(MainManager.actorID == param1.userID)
         {
            return;
         }
         if(friendLength >= F_MAX)
         {
            return;
         }
         if(_friendList.containsKey(param1.userID))
         {
            return;
         }
         if(_blackList.remove(param1.userID))
         {
            dispatchEvent(new RelationEvent(RelationEvent.BLACK_REMOVE,param1.userID));
         }
         _friendList.add(param1.userID,param1);
         dispatchEvent(new RelationEvent(RelationEvent.FRIEND_ADD,param1.userID));
      }
      
      public static function removeFriend(param1:uint) : void
      {
         var userID:uint = param1;
         if(!_friendList.containsKey(userID))
         {
            return;
         }
         SocketConnection.addCmdListener(CommandID.FRIEND_REMOVE,function(param1:SocketEvent):void
         {
            if(_friendList.remove(userID))
            {
               dispatchEvent(new RelationEvent(RelationEvent.FRIEND_REMOVE,userID));
            }
            SocketConnection.removeCmdListener(CommandID.FRIEND_REMOVE,arguments.callee);
         });
         SocketConnection.send(CommandID.FRIEND_REMOVE,userID);
      }
      
      public static function addBlack(param1:uint) : void
      {
         var userID:uint = param1;
         if(MainManager.actorID == userID)
         {
            Alarm.show("不能把自己添加进黑名单！");
            return;
         }
         if(_blackList.containsKey(userID))
         {
            Alarm.show("用户已经存在于黑名单！");
            return;
         }
         SocketConnection.addCmdListener(CommandID.BLACK_ADD,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.BLACK_ADD,arguments.callee);
            var _loc3_:ByteArray = param1.data as ByteArray;
            var _loc4_:uint = _loc3_.readUnsignedInt();
            var _loc5_:UserInfo = new UserInfo();
            _loc5_.userID = _loc4_;
            _loc5_.timePoke = 0;
            if(_friendList.remove(_loc4_))
            {
               dispatchEvent(new RelationEvent(RelationEvent.FRIEND_REMOVE,_loc4_));
            }
            _blackList.add(_loc4_,_loc5_);
            dispatchEvent(new RelationEvent(RelationEvent.BLACK_ADD,_loc4_));
            upDateInfo(_loc4_);
         });
         SocketConnection.send(CommandID.BLACK_ADD,userID);
      }
      
      public static function addBlackInfo(param1:UserInfo) : void
      {
         if(MainManager.actorID == param1.userID)
         {
            return;
         }
         if(_blackList.containsKey(param1.userID))
         {
            return;
         }
         if(_friendList.remove(param1.userID))
         {
            dispatchEvent(new RelationEvent(RelationEvent.FRIEND_REMOVE,param1.userID));
         }
         _blackList.add(param1.userID,param1);
         dispatchEvent(new RelationEvent(RelationEvent.BLACK_ADD,param1.userID));
      }
      
      public static function removeBlack(param1:uint) : void
      {
         var userID:uint = param1;
         if(!_blackList.containsKey(userID))
         {
            return;
         }
         SocketConnection.addCmdListener(CommandID.BLACK_REMOVE,function(param1:SocketEvent):void
         {
            if(_blackList.remove(userID))
            {
               dispatchEvent(new RelationEvent(RelationEvent.BLACK_REMOVE,userID));
            }
            SocketConnection.removeCmdListener(CommandID.BLACK_REMOVE,arguments.callee);
         });
         SocketConnection.send(CommandID.BLACK_REMOVE,userID);
      }
      
      public static function answerFriend(param1:uint, param2:Boolean) : void
      {
         SocketConnection.send(CommandID.FRIEND_ANSWER,param1,uint(param2));
      }
      
      public static function setOnLineFriend() : void
      {
         var k:int = 0;
         var info:UserInfo = null;
         var arr:Array = _friendList.getKeys();
         var arrLen:int = int(arr.length);
         k = 0;
         while(k < arrLen)
         {
            info = _friendList.getValue(arr[k]) as UserInfo;
            info.serverID = 0;
            k++;
         }
         UserInfoManager.seeOnLine(arr,function(param1:Array):void
         {
            var _loc2_:OnLineInfo = null;
            var _loc3_:UserInfo = null;
            _friendOnLineLength = param1.length;
            if(_friendOnLineLength == 0)
            {
               dispatchEvent(new RelationEvent(RelationEvent.FRIEND_UPDATE_ONLINE));
               setFriendInfo();
               return;
            }
            var _loc4_:int = 0;
            while(_loc4_ < _friendOnLineLength)
            {
               _loc2_ = param1[_loc4_] as OnLineInfo;
               _loc3_ = _friendList.getValue(_loc2_.userID) as UserInfo;
               if(Boolean(_loc3_))
               {
                  _loc3_.mapID = _loc2_.mapID;
                  _loc3_.serverID = _loc2_.serverID;
               }
               _loc4_++;
            }
            dispatchEvent(new RelationEvent(RelationEvent.FRIEND_UPDATE_ONLINE));
            setFriendInfo();
         });
      }
      
      public static function setFriendInfo() : void
      {
         var _fInfos:Array = null;
         var _fKeyLen:int = 0;
         _fInfos = null;
         _fKeyLen = 0;
         var loopInfo:Function = function(param1:int):void
         {
            var i:int = param1;
            if(i == _fKeyLen)
            {
               dispatchEvent(new RelationEvent(RelationEvent.UPDATE_INFO));
               _fInfos = null;
               _fKeyLen = NaN;
               if(Boolean(_relSO))
               {
                  _relSO.data[SO_FRIEND] = _friendList.getValues();
                  SOManager.flush(_relSO);
               }
               return;
            }
            UserInfoManager.upDateSimpleInfo(_fInfos[i],function():void
            {
               ++i;
               loopInfo(i);
            });
         };
         if(!_isFriendInfo)
         {
            return;
         }
         _isFriendInfo = false;
         if(_soFriendTimePokeSet == null)
         {
            _fInfos = _friendList.getValues();
         }
         else
         {
            _fInfos = _soFriendTimePokeSet.toArray();
         }
         _fKeyLen = int(_fInfos.length);
         if(_fKeyLen == 0)
         {
            return;
         }
         loopInfo(0);
      }
      
      public static function setBlackInfo() : void
      {
         var _fInfos:Array = null;
         var _fKeyLen:int = 0;
         _fInfos = null;
         _fKeyLen = 0;
         var loopInfo:Function = function(param1:int):void
         {
            var i:int = param1;
            if(i == _fKeyLen)
            {
               dispatchEvent(new RelationEvent(RelationEvent.UPDATE_INFO));
               _fInfos = null;
               _fKeyLen = NaN;
               return;
            }
            UserInfoManager.upDateSimpleInfo(_fInfos[i],function():void
            {
               ++i;
               loopInfo(i);
            });
         };
         if(!_isBlackInfo)
         {
            return;
         }
         _isBlackInfo = false;
         _fInfos = _blackList.getValues();
         _fKeyLen = int(_fInfos.length);
         loopInfo(0);
      }
      
      public static function upDateInfo(param1:uint) : void
      {
         var rel:UserInfo = null;
         var id:uint = param1;
         rel = null;
         rel = _friendList.getValue(id) as UserInfo;
         if(rel == null)
         {
            rel = _blackList.getValue(id) as UserInfo;
         }
         if(Boolean(rel))
         {
            UserInfoManager.upDateSimpleInfo(rel,function():void
            {
               dispatchEvent(new RelationEvent(RelationEvent.UPDATE_INFO,rel.userID));
            });
         }
      }
      
      public static function upDateInfoForSimpleInfo(param1:UserInfo) : void
      {
         var _loc2_:UserInfo = _friendList.getValue(param1.userID) as UserInfo;
         if(_loc2_ == null)
         {
            _loc2_ = _blackList.getValue(param1.userID) as UserInfo;
         }
         if(Boolean(_loc2_))
         {
            _loc2_.hasSimpleInfo = true;
            _loc2_.nick = param1.nick;
            _loc2_.color = param1.color;
            _loc2_.texture = param1.texture;
            _loc2_.vip = param1.vip;
            _loc2_.status = param1.status;
            _loc2_.mapID = param1.mapID;
            _loc2_.isCanBeTeacher = param1.isCanBeTeacher;
            _loc2_.teacherID = param1.teacherID;
            _loc2_.studentID = param1.studentID;
            _loc2_.graduationCount = param1.graduationCount;
            _loc2_.clothes = param1.clothes.slice();
            dispatchEvent(new RelationEvent(RelationEvent.UPDATE_INFO,_loc2_.userID));
         }
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(instance == null)
         {
            instance = new EventDispatcher();
         }
         return instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            getInstance().dispatchEvent(param1);
         }
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
   }
}

