package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.event.ChatEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.ChatInfo;
   import com.robot.core.info.InformInfo;
   import com.robot.core.info.TeamChatInfo;
   import com.robot.core.info.team.TeamInformInfo;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.ds.HashMap;
   
   public class MessageManager
   {
      
      private static var instance:EventDispatcher;
      
      public static const SYS_TYPE:uint = 1;
      
      public static const TEAM_TYPE:uint = 2;
      
      public static const TEAM_CHAT_TYPE:uint = 3;
      
      private static const MAX:int = 300;
      
      private static var _userMap:HashMap = new HashMap();
      
      private static var _unReadList:Array = [];
      
      private static var teamAddInfoMap:HashMap = new HashMap();
      
      public static var inviteJoinTeamMap:HashMap = new HashMap();
      
      public static var friendAddInfoMap:HashMap = new HashMap();
      
      public static var friendAnswerInfoMap:HashMap = new HashMap();
      
      public static var friendRemoveInfoMap:HashMap = new HashMap();
      
      public function MessageManager()
      {
         super();
      }
      
      public static function addChatInfo(param1:ChatInfo) : void
      {
         if(RelationManager.isBlack(param1.senderID))
         {
            return;
         }
         var _loc2_:String = ChatEvent.TALK + param1.talkID.toString();
         if(hasEventListener(_loc2_))
         {
            dispatchEvent(new ChatEvent(_loc2_,param1));
         }
         else
         {
            _unReadList.push({
               "_id":param1.talkID,
               "_info":param1
            });
            dispatchEvent(new RobotEvent(RobotEvent.MESSAGE));
         }
         var _loc3_:Array = _userMap.getValue(param1.talkID);
         if(_loc3_ == null)
         {
            _loc3_ = [];
            _userMap.add(param1.talkID,_loc3_);
         }
         _loc3_.push(param1);
         if(_loc3_.length > MAX)
         {
            _loc3_.shift();
         }
      }
      
      public static function addInformInfo(param1:InformInfo) : void
      {
         if(param1.type == CommandID.FRIEND_ADD)
         {
            if(RelationManager.friendLength >= RelationManager.F_MAX)
            {
               return;
            }
            if(friendAddInfoMap.containsKey(param1.userID))
            {
               dispatchEvent(new RobotEvent(RobotEvent.ADD_FRIEND_MSG));
               return;
            }
            friendAddInfoMap.add(param1.userID,param1);
            dispatchEvent(new RobotEvent(RobotEvent.ADD_FRIEND_MSG));
            return;
         }
         if(param1.type == CommandID.TEAM_ADD)
         {
            if(teamAddInfoMap.containsKey(param1.userID))
            {
               return;
            }
            teamAddInfoMap.add(param1.userID,param1);
         }
         _unReadList.push({
            "_id":SYS_TYPE,
            "_info":param1
         });
         dispatchEvent(new RobotEvent(RobotEvent.MESSAGE));
      }
      
      public static function addTeamInformInfo(param1:TeamInformInfo) : void
      {
         if(param1.type == CommandID.TEAM_INVITE_TO_JOIN)
         {
            inviteJoinTeamMap.add(param1.userID,param1);
            dispatchEvent(new RobotEvent(RobotEvent.ADD_TEAM_MSG));
            return;
         }
         _unReadList.push({
            "_id":TEAM_TYPE,
            "_info":param1
         });
         dispatchEvent(new RobotEvent(RobotEvent.MESSAGE));
      }
      
      public static function addTeamChatInfo(param1:TeamChatInfo) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         for each(_loc2_ in _unReadList)
         {
            if(_loc2_._id == TEAM_CHAT_TYPE)
            {
               _loc3_ = true;
               break;
            }
         }
         if(!_loc3_)
         {
            _unReadList.push({
               "_id":TEAM_CHAT_TYPE,
               "_info":param1
            });
            dispatchEvent(new RobotEvent(RobotEvent.MESSAGE));
         }
      }
      
      public static function removeUnUserID(param1:uint) : void
      {
         var userID:uint = param1;
         _unReadList = _unReadList.filter(function(param1:Object, param2:int, param3:Array):Boolean
         {
            if(param1._id == userID)
            {
               return false;
            }
            return true;
         });
      }
      
      public static function getChatInfo(param1:uint) : Array
      {
         return _userMap.getValue(param1);
      }
      
      public static function getInformInfo() : InformInfo
      {
         var _loc1_:InformInfo = null;
         var _loc2_:int = int(_unReadList.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_unReadList[_loc3_]._id == SYS_TYPE)
            {
               _loc1_ = _unReadList[_loc3_]._info;
               _unReadList.splice(_loc3_,1);
               if(_loc1_.type == CommandID.TEAM_ADD)
               {
                  if(teamAddInfoMap.containsKey(_loc1_.userID))
                  {
                     teamAddInfoMap.remove(_loc1_.userID);
                  }
               }
               else if(_loc1_.type == CommandID.FRIEND_ADD)
               {
                  if(friendAddInfoMap.containsKey(_loc1_.userID))
                  {
                     friendAddInfoMap.remove(_loc1_.userID);
                  }
               }
               return _loc1_;
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function getInviteJoinTeamInfo(param1:uint) : TeamInformInfo
      {
         if(inviteJoinTeamMap.containsKey(param1))
         {
            return inviteJoinTeamMap.getValue(param1);
         }
         return null;
      }
      
      public static function removeAddFridInfo(param1:uint) : void
      {
         if(friendAddInfoMap.containsKey(param1))
         {
            friendAddInfoMap.remove(param1);
         }
      }
      
      public static function removeInviteJoinTeamInfo(param1:uint) : void
      {
         if(inviteJoinTeamMap.containsKey(param1))
         {
            inviteJoinTeamMap.remove(param1);
         }
      }
      
      public static function getTeamInformInfo() : TeamInformInfo
      {
         var _loc1_:TeamInformInfo = null;
         var _loc2_:int = int(_unReadList.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_unReadList[_loc3_]._id == TEAM_TYPE)
            {
               _loc1_ = _unReadList[_loc3_]._info;
               _unReadList.splice(_loc3_,1);
               return _loc1_;
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function getTeamChatInfo() : TeamChatInfo
      {
         var _loc1_:TeamChatInfo = null;
         var _loc2_:int = int(_unReadList.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(_unReadList[_loc3_]._id == TEAM_CHAT_TYPE)
            {
               _loc1_ = _unReadList[_loc3_]._info;
               _unReadList.splice(_loc3_,1);
               return _loc1_;
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function getFristUnReadID() : uint
      {
         if(_unReadList.length > 0)
         {
            return _unReadList[0]._id;
         }
         return 0;
      }
      
      public static function unReadLength() : int
      {
         return _unReadList.length;
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
         getInstance().dispatchEvent(param1);
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

