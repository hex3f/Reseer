package com.robot.core.info
{
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.team.TeamInfo;
   import com.robot.core.info.teamPK.TeamPKInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.taomee.utils.BitUtil;
   
   public class UserInfo
   {
      
      public var priorLevel:uint;
      
      public var userID:uint;
      
      public var timePoke:uint;
      
      public var hasSimpleInfo:Boolean = false;
      
      public var hasMoreInfo:Boolean = false;
      
      public var nick:String = "";
      
      public var vip:uint;
      
      public var viped:uint;
      
      public var color:uint;
      
      public var texture:uint;
      
      public var energy:uint;
      
      public var coins:uint;
      
      public var fightBadge:uint;
      
      public var status:uint;
      
      public var mapType:uint;
      
      public var mapID:uint;
      
      public var actionType:uint;
      
      public var pos:Point = new Point();
      
      public var spiritTime:uint;
      
      public var spiritID:uint;
      
      public var clothes:Array = [];
      
      public var ore:uint;
      
      public var serverID:uint;
      
      public var action:uint;
      
      public var direction:uint;
      
      public var changeShape:uint;
      
      public var petNum:uint;
      
      public var timeToday:uint;
      
      public var loginCnt:uint;
      
      public var inviter:uint;
      
      public var teamID:uint;
      
      public var isCanBeTeacher:Boolean;
      
      public var teacherID:uint;
      
      public var studentID:uint;
      
      public var graduationCount:uint;
      
      public var maxPuniLv:uint;
      
      public var regTime:uint;
      
      public var petAllNum:uint;
      
      public var petMaxLev:uint;
      
      public var bossAchievement:Array = [];
      
      public var fightFlag:uint;
      
      public var monKingWin:uint;
      
      public var messWin:uint;
      
      public var curStage:uint;
      
      public var maxStage:uint;
      
      public var curFreshStage:uint;
      
      public var maxFreshStage:uint;
      
      public var maxArenaWins:uint;
      
      public var badge:uint;
      
      public var reserved:ByteArray;
      
      public var superNono:Boolean;
      
      public var hasNono:Boolean;
      
      public var nonoState:Array = [];
      
      public var nonoNick:String = "";
      
      public var nonoColor:uint;
      
      public var timeLimit:uint;
      
      public var dsFlag:uint;
      
      public var newInviteeCnt:uint;
      
      public var freshManBonus:uint;
      
      public var dailyResArr:Array = [];
      
      public var nonoChipList:Array = [];
      
      public var teamInfo:TeamInfo;
      
      public var teamPKInfo:TeamPKInfo;
      
      public var playerForm:Boolean;
      
      public var transTime:uint;
      
      public var vipLevel:uint;
      
      public var vipValue:uint;
      
      public var vipStage:uint;
      
      public var autoCharge:uint;
      
      public var vipEndTime:uint;
      
      public var autoFight:uint;
      
      public var autoFightTimes:uint;
      
      public var twoTimes:uint;
      
      public var threeTimes:uint;
      
      public var monBtlMedal:uint;
      
      public var energyTimes:uint;
      
      public var learnTimes:uint;
      
      public var recordCnt:uint;
      
      public var obtainTm:uint;
      
      public var soulBeadItemID:uint;
      
      public var expireTm:uint;
      
      public var fuseTimes:uint;
      
      public var canReadSchedule:Boolean;
      
      public var petDV:uint;
      
      public var sysTime:uint;
      
      public var curTitle:uint;
      
      public var petSkin:uint;
      
      public function UserInfo()
      {
         super();
      }
      
      public static function setForPeoleInfo(param1:UserInfo, param2:IDataInput) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         param1.hasSimpleInfo = true;
         param1.sysTime = param2.readInt();
         param1.userID = param2.readUnsignedInt();
         param1.nick = param2.readUTFBytes(16);
         param1.color = param2.readUnsignedInt();
         param1.texture = param2.readUnsignedInt();
         var _loc5_:uint = param2.readUnsignedInt();
         param1.vip = BitUtil.getBit(_loc5_,0);
         param1.viped = BitUtil.getBit(_loc5_,1);
         param1.vipStage = param2.readUnsignedInt();
         param1.actionType = param2.readUnsignedInt();
         param1.pos = new Point(param2.readUnsignedInt(),param2.readUnsignedInt());
         param1.action = param2.readUnsignedInt();
         param1.direction = param2.readUnsignedInt();
         param1.changeShape = param2.readUnsignedInt();
         param1.spiritTime = param2.readUnsignedInt();
         param1.spiritID = param2.readUnsignedInt();
         param1.petDV = param2.readUnsignedInt();
         param1.petSkin = param2.readUnsignedInt();
         param1.fightFlag = param2.readUnsignedInt();
         param1.teacherID = param2.readUnsignedInt();
         param1.studentID = param2.readUnsignedInt();
         var _loc6_:uint = param2.readUnsignedInt();
         var _loc7_:int = 0;
         while(_loc7_ < 32)
         {
            param1.nonoState.push(BitUtil.getBit(_loc6_,_loc7_));
            _loc7_++;
         }
         param1.nonoColor = param2.readUnsignedInt();
         param1.superNono = Boolean(param2.readUnsignedInt());
         param1.playerForm = Boolean(param2.readUnsignedInt());
         param1.transTime = param2.readUnsignedInt();
         var _loc8_:TeamInfo = new TeamInfo();
         _loc8_.id = param2.readUnsignedInt();
         _loc8_.coreCount = param2.readUnsignedInt();
         _loc8_.isShow = Boolean(param2.readUnsignedInt());
         param1.teamInfo = _loc8_;
         _loc8_.logoBg = param2.readShort();
         _loc8_.logoIcon = param2.readShort();
         _loc8_.logoColor = param2.readShort();
         _loc8_.txtColor = param2.readShort();
         _loc8_.logoWord = param2.readUTFBytes(4);
         var _loc9_:uint = param2.readUnsignedInt();
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc3_ = param2.readUnsignedInt();
            _loc4_ = param2.readUnsignedInt();
            param1.clothes.push(new PeopleItemInfo(_loc3_,_loc4_));
            _loc10_++;
         }
         param1.curTitle = param2.readUnsignedInt();
      }
      
      public static function setForLoginInfo(param1:UserInfo, param2:IDataInput) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         param1.hasSimpleInfo = true;
         param1.userID = param2.readUnsignedInt();
         param1.regTime = param2.readUnsignedInt();
         param1.nick = param2.readUTFBytes(16);
         var _loc5_:uint = param2.readUnsignedInt();
         param1.vip = BitUtil.getBit(_loc5_,0);
         param1.viped = BitUtil.getBit(_loc5_,1);
         param1.dsFlag = param2.readUnsignedInt();
         param1.color = param2.readUnsignedInt();
         param1.texture = param2.readUnsignedInt();
         param1.energy = param2.readUnsignedInt();
         param1.coins = param2.readUnsignedInt();
         param1.fightBadge = param2.readUnsignedInt();
         param1.mapID = param2.readUnsignedInt();
         param1.pos = new Point(param2.readUnsignedInt(),param2.readUnsignedInt());
         param1.timeToday = param2.readUnsignedInt();
         param1.timeLimit = param2.readUnsignedInt();
         MainManager.isClothHalfDay = Boolean(param2.readByte());
         MainManager.isRoomHalfDay = Boolean(param2.readByte());
         MainManager.iFortressHalfDay = Boolean(param2.readByte());
         MainManager.isHQHalfDay = Boolean(param2.readByte());
         param1.loginCnt = param2.readUnsignedInt();
         param1.inviter = param2.readUnsignedInt();
         param1.newInviteeCnt = param2.readUnsignedInt();
         param1.vipLevel = param2.readUnsignedInt();
         param1.vipValue = param2.readUnsignedInt();
         param1.vipStage = param2.readUnsignedInt();
         if(param1.vipStage > 5)
         {
            param1.vipStage = 5;
         }
         if(param1.vipStage == 0)
         {
            param1.vipStage = 1;
         }
         param1.autoCharge = param2.readUnsignedInt();
         param1.vipEndTime = param2.readUnsignedInt();
         param1.freshManBonus = param2.readUnsignedInt();
         var _loc6_:int = 0;
         while(_loc6_ < 80)
         {
            param1.nonoChipList.push(Boolean(param2.readByte()));
            _loc6_++;
         }
         var _loc7_:int = 0;
         while(_loc7_ < 50)
         {
            param1.dailyResArr.push(param2.readByte());
            _loc7_++;
         }
         param1.teacherID = param2.readUnsignedInt();
         param1.studentID = param2.readUnsignedInt();
         param1.graduationCount = param2.readUnsignedInt();
         param1.maxPuniLv = param2.readUnsignedInt();
         param1.petMaxLev = param2.readUnsignedInt();
         param1.petAllNum = param2.readUnsignedInt();
         param1.monKingWin = param2.readUnsignedInt();
         param1.curStage = param2.readUnsignedInt() + 1;
         param1.maxStage = param2.readUnsignedInt();
         param1.curFreshStage = param2.readUnsignedInt();
         param1.maxFreshStage = param2.readUnsignedInt();
         param1.maxArenaWins = param2.readUnsignedInt();
         param1.twoTimes = param2.readUnsignedInt();
         param1.threeTimes = param2.readUnsignedInt();
         param1.autoFight = param2.readUnsignedInt();
         param1.autoFightTimes = param2.readUnsignedInt();
         param1.energyTimes = param2.readUnsignedInt();
         param1.learnTimes = param2.readUnsignedInt();
         param1.monBtlMedal = param2.readUnsignedInt();
         param1.recordCnt = param2.readUnsignedInt();
         param1.obtainTm = param2.readUnsignedInt();
         param1.soulBeadItemID = param2.readUnsignedInt();
         param1.expireTm = param2.readUnsignedInt();
         param1.fuseTimes = param2.readUnsignedInt();
         param1.hasNono = Boolean(param2.readUnsignedInt());
         param1.superNono = Boolean(param2.readUnsignedInt());
         var _loc8_:uint = param2.readUnsignedInt();
         var _loc9_:int = 0;
         while(_loc9_ < 32)
         {
            param1.nonoState.push(BitUtil.getBit(_loc8_,_loc9_));
            _loc9_++;
         }
         param1.nonoColor = param2.readUnsignedInt();
         param1.nonoNick = param2.readUTFBytes(16);
         param1.teamInfo = new TeamInfo(param2);
         param1.teamPKInfo = new TeamPKInfo(param2);
         param2.readByte();
         param1.badge = param2.readUnsignedInt();
         var _loc10_:ByteArray = new ByteArray();
         param2.readBytes(_loc10_,0,27);
         param1.reserved = _loc10_;
         var _loc11_:int = 0;
         while(_loc11_ < 500)
         {
            TasksManager.taskList.push(param2.readUnsignedByte());
            _loc11_++;
         }
         var _loc12_:Array = TasksManager.taskList;
         param1.isCanBeTeacher = TasksManager.getTaskStatus(201) == 3;
         param1.petNum = param2.readUnsignedInt();
         PetManager.initData(param2,param1.petNum);
         var _loc13_:uint = param2.readUnsignedInt();
         var _loc14_:Number = 0;
         while(_loc14_ < _loc13_)
         {
            _loc3_ = param2.readUnsignedInt();
            _loc4_ = param2.readUnsignedInt();
            param1.clothes.push(new PeopleItemInfo(_loc3_,_loc4_));
            _loc14_++;
         }
         param1.curTitle = param2.readUnsignedInt();
         param1.bossAchievement = [];
         var _loc15_:int = 0;
         while(_loc15_ < 200)
         {
            param1.bossAchievement.push(Boolean(param2.readByte()));
            _loc15_++;
         }
      }
      
      public static function setForSimpleInfo(param1:UserInfo, param2:IDataInput) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         param1.hasSimpleInfo = true;
         ByteArray(param2).position = 0;
         param1.userID = param2.readUnsignedInt();
         param1.nick = param2.readUTFBytes(16);
         param1.color = param2.readUnsignedInt();
         param1.texture = param2.readUnsignedInt();
         param1.vip = param2.readUnsignedInt();
         param1.status = param2.readUnsignedInt();
         param1.mapType = param2.readUnsignedInt();
         param1.mapID = param2.readUnsignedInt();
         param1.isCanBeTeacher = param2.readUnsignedInt() == 1;
         param1.teacherID = param2.readUnsignedInt();
         param1.studentID = param2.readUnsignedInt();
         param1.graduationCount = param2.readUnsignedInt();
         param1.vipLevel = param2.readUnsignedInt();
         var _loc5_:TeamInfo = new TeamInfo();
         _loc5_.id = param2.readUnsignedInt();
         _loc5_.isShow = Boolean(param2.readUnsignedInt());
         param1.teamInfo = _loc5_;
         param1.teamID = _loc5_.id;
         var _loc6_:uint = param2.readUnsignedInt();
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc3_ = param2.readUnsignedInt();
            _loc4_ = param2.readUnsignedInt();
            param1.clothes.push(new PeopleItemInfo(_loc3_,_loc4_));
            _loc7_++;
         }
      }
      
      public static function setForMoreInfo(param1:UserInfo, param2:IDataInput) : void
      {
         param1.hasMoreInfo = true;
         param1.userID = param2.readUnsignedInt();
         param1.nick = param2.readUTFBytes(16);
         param1.regTime = param2.readUnsignedInt();
         param1.petAllNum = param2.readUnsignedInt();
         param1.petMaxLev = param2.readUnsignedInt();
         param1.bossAchievement = [];
         var _loc3_:int = 0;
         while(_loc3_ < 200)
         {
            param1.bossAchievement.push(Boolean(param2.readByte()));
            _loc3_++;
         }
         param1.graduationCount = param2.readUnsignedInt();
         param1.monKingWin = param2.readUnsignedInt();
         param1.messWin = param2.readUnsignedInt();
         param1.maxStage = param2.readUnsignedInt();
         param1.maxArenaWins = param2.readUnsignedInt();
         param1.curTitle = param2.readUnsignedInt();
      }
      
      public function get clothIDs() : Array
      {
         var _loc1_:PeopleItemInfo = null;
         var _loc2_:Array = [];
         for each(_loc1_ in this.clothes)
         {
            _loc2_.push(_loc1_.id);
         }
         return _loc2_;
      }
      
      public function get clothMaxLevel() : uint
      {
         var _loc1_:PeopleItemInfo = null;
         var _loc2_:* = 0;
         for each(_loc1_ in this.clothes)
         {
            _loc2_ = Math.max(_loc2_,_loc1_.level);
         }
         return _loc2_;
      }
   }
}

