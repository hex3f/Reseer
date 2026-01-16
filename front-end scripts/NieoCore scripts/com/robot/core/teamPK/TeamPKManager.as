package com.robot.core.teamPK
{
   import com.robot.core.CommandID;
   import com.robot.core.controller.MouseController;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.event.TeamPKEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.info.teamPK.ShooterInfo;
   import com.robot.core.info.teamPK.SomeoneJoinInfo;
   import com.robot.core.info.teamPK.SuperNonoShieldInfo;
   import com.robot.core.info.teamPK.TeamPKBeShotInfo;
   import com.robot.core.info.teamPK.TeamPKBuildingListInfo;
   import com.robot.core.info.teamPK.TeamPKFreezeInfo;
   import com.robot.core.info.teamPK.TeamPKJoinInfo;
   import com.robot.core.info.teamPK.TeamPKNoteInfo;
   import com.robot.core.info.teamPK.TeamPKResultInfo;
   import com.robot.core.info.teamPK.TeamPKSignInfo;
   import com.robot.core.info.teamPK.TeamPKTeamInfo;
   import com.robot.core.info.teamPK.TeamPkStInfo;
   import com.robot.core.info.teamPK.TeamPkUserInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.UserInfoManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.map.MapType;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.spriteModelAdditive.PeopleBloodBar;
   import com.robot.core.mode.spriteModelAdditive.SpriteBloodBar;
   import com.robot.core.mode.spriteModelAdditive.SpriteFreeze;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.teamInstallation.TeamInfoManager;
   import com.robot.core.teamPK.shotActive.AutoShotManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class TeamPKManager
   {
      
      private static var homeTeamID:uint;
      
      private static var awayTeamID:uint;
      
      public static var sign:ByteArray;
      
      private static var homeList:Array;
      
      private static var awayList:Array;
      
      public static var TEAM:uint;
      
      private static var loader:Loader;
      
      private static var waitPanel:MovieClip;
      
      public static var enemyInfo:TeamPKTeamInfo;
      
      public static var enemyBuildingList:Array;
      
      public static var homeHeaderHp:uint;
      
      public static var awayHeaderHp:uint;
      
      public static var isShowPanel:Boolean;
      
      public static var myMaxHp:uint;
      
      public static var myHp:uint;
      
      private static var oldMap:uint;
      
      private static var infoIcon:InteractiveObject;
      
      private static var fun:Function;
      
      private static var infoPanel:MovieClip;
      
      private static var teamPKMessPanel:TeamPKMessPanel;
      
      private static var win_mc:MovieClip;
      
      public static var teamPkSituationInfo:TeamPkStInfo;
      
      private static var instance:EventDispatcher;
      
      private static var URL:String = "resource/eff/shotEffect.swf";
      
      private static const MAP_ID:uint = 700001;
      
      public static var PK_STATUS:uint = 0;
      
      public static const START:uint = 1;
      
      public static const OPEN_DOOR:uint = 2;
      
      public static const OVER:uint = 3;
      
      public static var inMap:Boolean = false;
      
      public static var isGetBuilding:Boolean = false;
      
      public static var buildingMap:HashMap = new HashMap();
      
      public static var homeBuildingMap:HashMap = new HashMap();
      
      public static var awayBuildingMap:HashMap = new HashMap();
      
      public static const HOME:uint = 1;
      
      public static const AWAY:uint = 2;
      
      private static var freezeIDs:Array = [];
      
      private static var noModelMaps:HashMap = new HashMap();
      
      public static const REDX:uint = 1880;
      
      public static const INIT_INFO:String = "initinfo";
      
      public static const INIT_HP:String = "inithp";
      
      private static var isSendB:Boolean = false;
      
      public function TeamPKManager()
      {
         super();
      }
      
      public static function closeWait() : void
      {
         setTimeout(function():void
         {
            if(oldMap != 0)
            {
               MapManager.changeMap(oldMap);
            }
            DisplayUtil.removeForParent(waitPanel,false);
         },200);
      }
      
      public static function setup() : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_PK_SIGN,onGetTeamSign);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_NOTE,onTeamPKNote);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_JOIN,onPKJoin);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_SOMEONE_JOIN_INFO,onSomeoneJoin);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_GET_BUILDING_INFO,onGetBuildingInfo);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_BE_SHOT,beShotHandler);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_FREEZE,onFreeze);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_USE_SHIELD,onUseShield);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_RESULT,resultHandler);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_NO_PET,noPetHandler);
         EventManager.addEventListener(RobotEvent.CREATED_MAP_USER,onCreateMapUser);
         if(!enemyInfo)
         {
            enemyInfo = new TeamPKTeamInfo();
         }
         if(!infoIcon)
         {
            infoIcon = TaskIconManager.getIcon("TeamPK_icon");
            infoIcon.addEventListener(MouseEvent.CLICK,showTaskPanel);
            ToolTipManager.add(infoIcon,"对抗赛消息");
         }
      }
      
      private static function noPetHandler(param1:SocketEvent) : void
      {
         Alarm.show("精灵对战失败！你没有可出战的精灵应对敌方的挑战。");
      }
      
      public static function showIcon() : void
      {
         TaskIconManager.addIcon(infoIcon);
      }
      
      public static function removeIcon() : void
      {
         TaskIconManager.delIcon(infoIcon);
         if(Boolean(teamPKMessPanel))
         {
            teamPKMessPanel.destroy();
         }
      }
      
      private static function showTaskPanel(param1:MouseEvent) : void
      {
         if(!teamPKMessPanel)
         {
            teamPKMessPanel = new TeamPKMessPanel();
            teamPKMessPanel.setup();
         }
         else
         {
            teamPKMessPanel.setup();
         }
      }
      
      public static function register() : void
      {
         SocketConnection.send(CommandID.TEAM_PK_SIGN);
      }
      
      public static function joinPK() : void
      {
         oldMap = MainManager.actorInfo.mapID;
         if(MainManager.actorInfo.teamPKInfo.homeTeamID == 0)
         {
            Alarm.show("你现在不能进入对抗赛");
         }
         fun = join;
         var _loc1_:MCLoader = new MCLoader(URL,LevelManager.appLevel,1,"正在进入对战系统");
         _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoadByJoin);
         _loc1_.doLoad();
      }
      
      private static function onLoadByRegister(param1:MCLoadEvent) : void
      {
         var closeBtn:SimpleButton = null;
         var num:uint = 0;
         var event:MCLoadEvent = param1;
         ShotBehaviorManager.setup(event.getLoader());
         waitPanel = ShotBehaviorManager.getMovieClip("pk_wait_panel");
         closeBtn = waitPanel["closeBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            closeWait();
         });
         num = Math.ceil(Math.random() * 3);
         waitPanel["mc"].gotoAndStop(num);
         MainManager.getStage().addChild(waitPanel);
         fun();
      }
      
      private static function onLoadByJoin(param1:MCLoadEvent) : void
      {
         ShotBehaviorManager.setup(param1.getLoader());
         fun();
      }
      
      public static function initBuildList() : void
      {
         if(TEAM == HOME)
         {
            enemyBuildingList = awayBuildinList;
         }
         else
         {
            enemyBuildingList = homeBuildinList;
         }
      }
      
      private static function onCreateMapUser(param1:RobotEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:TeamPKFreezeInfo = null;
         var _loc4_:BasePeoleModel = null;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:BasePeoleModel = null;
         var _loc8_:Point = null;
         var _loc9_:Array = noModelMaps.getKeys();
         for each(_loc2_ in _loc9_)
         {
            _loc4_ = UserManager.getUserModel(_loc2_);
            if(Boolean(_loc4_))
            {
               if(_loc4_.info.teamInfo.id == homeTeamID)
               {
                  _loc4_.bloodBar.colorType = PeopleBloodBar.RED;
               }
               else
               {
                  _loc4_.bloodBar.colorType = PeopleBloodBar.BLUE;
               }
               noModelMaps.remove(_loc2_);
            }
         }
         for each(_loc3_ in freezeIDs)
         {
            _loc5_ = _loc3_.flag;
            _loc6_ = _loc3_.uid;
            _loc7_ = UserManager.getUserModel(_loc6_);
            if(Boolean(_loc7_))
            {
               if(_loc5_ == 1)
               {
                  _loc8_ = MapConfig.getMapPeopleXY(0,homeTeamID);
                  if(_loc7_.info.teamInfo.id == homeTeamID)
                  {
                     _loc7_.x = _loc8_.x;
                     _loc7_.y = _loc8_.y;
                  }
                  else
                  {
                     _loc7_.x = _loc8_.x + REDX;
                     _loc8_.x += REDX;
                     _loc7_.y = _loc8_.y;
                  }
                  _loc7_.additive = [new SpriteFreeze()];
                  if(_loc6_ == MainManager.actorID)
                  {
                     if(TEAM == HOME)
                     {
                        LevelManager.moveToLeft();
                     }
                     else
                     {
                        LevelManager.moveToRight();
                     }
                     _loc7_.walkAction(_loc8_);
                     dispatchEvent(new Event(INIT_INFO));
                     LevelManager.closeMouseEvent();
                  }
               }
               else
               {
                  _loc7_.filters = [];
                  if(_loc6_ == MainManager.actorID)
                  {
                     LevelManager.openMouseEvent();
                  }
               }
            }
         }
         freezeIDs = [];
      }
      
      private static function showWin(param1:uint) : void
      {
         if(param1 != 2)
         {
            if(TEAM == HOME)
            {
               if(param1 == 0)
               {
                  win_mc = ShotBehaviorManager.getMovieClip("AwayWin");
               }
               else
               {
                  win_mc = ShotBehaviorManager.getMovieClip("HomeWin");
               }
            }
            else if(param1 == 0)
            {
               win_mc = ShotBehaviorManager.getMovieClip("HomeWin");
            }
            else
            {
               win_mc = ShotBehaviorManager.getMovieClip("AwayWin");
            }
            if(Boolean(win_mc))
            {
               win_mc.x = MainManager.getStageWidth() / 2 - 100;
               win_mc.y = MainManager.getStageHeight() / 2;
               win_mc.addFrameScript(win_mc.totalFrames - 1,onEnd);
               LevelManager.topLevel.addChild(win_mc);
            }
         }
      }
      
      private static function onEnd() : void
      {
         win_mc.addFrameScript(win_mc.totalFrames - 1,null);
         LevelManager.topLevel.removeChild(win_mc);
         win_mc = null;
      }
      
      public static function resultHandler(param1:SocketEvent) : void
      {
         var _loc2_:TeamPKResultInfo = param1.data as TeamPKResultInfo;
         var _loc3_:TeamPKResultPanel = new TeamPKResultPanel();
         _loc3_.setup(_loc2_);
         showWin(_loc2_.result);
         PK_STATUS = 0;
      }
      
      public static function getTeamSituation() : void
      {
         SocketConnection.send(CommandID.TEAM_PK_SITUATION);
         SocketConnection.addCmdListener(CommandID.TEAM_PK_SITUATION,getPkSituationHandler);
      }
      
      private static function getPkSituationHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_PK_SITUATION,getPkSituationHandler);
         var _loc2_:TeamPkStInfo = param1.data as TeamPkStInfo;
         if(_loc2_.flag == 0)
         {
            return;
         }
         teamPkSituationInfo = _loc2_;
         dispatchEvent(new Event(INIT_INFO));
      }
      
      private static function _register() : void
      {
         MapManager.styleID = MAP_ID;
         MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onSwitchMap);
         MapManager.changeMap(MainManager.actorInfo.teamInfo.id,0,MapType.PK_TYPE);
      }
      
      private static function onGetTeamSign(param1:SocketEvent) : void
      {
         var _loc2_:TeamPKSignInfo = param1.data as TeamPKSignInfo;
         sign = _loc2_.sign;
         oldMap = MainManager.actorInfo.mapID;
         fun = _register;
         var _loc3_:MCLoader = new MCLoader(URL,LevelManager.appLevel,1,"正在进入对战系统");
         _loc3_.addEventListener(MCLoadEvent.SUCCESS,onLoadByRegister);
         _loc3_.doLoad();
      }
      
      private static function onSwitchMap(param1:MapEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,onSwitchMap);
         SocketConnection.send(CommandID.TEAM_PK_REGISTER,TeamPKManager.sign);
      }
      
      private static function getEnamyTeamInfo() : void
      {
         if(awayTeamID == 0)
         {
            return;
         }
         TeamInfoManager.getSimpleTeamInfo(awayTeamID,function(param1:SimpleTeamInfo):void
         {
            var info:SimpleTeamInfo = param1;
            enemyInfo.ename = info.name;
            enemyInfo.elevel = info.level;
            enemyInfo.eInfo = info;
            UserInfoManager.getInfo(info.leader,function(param1:UserInfo):void
            {
               enemyInfo.eLeader = param1.nick;
               getMyTeamInfo();
            });
         });
      }
      
      private static function getMyTeamInfo() : void
      {
         TeamInfoManager.getSimpleTeamInfo(homeTeamID,function(param1:SimpleTeamInfo):void
         {
            var info1:SimpleTeamInfo = param1;
            enemyInfo.myName = info1.name;
            enemyInfo.myLevel = info1.level;
            enemyInfo.myInfo = info1;
            UserInfoManager.getInfo(info1.leader,function(param1:UserInfo):void
            {
               enemyInfo.myLeader = param1.nick;
            });
         });
      }
      
      private static function onTeamPKNote(param1:SocketEvent) : void
      {
         var _loc2_:TeamPKNoteInfo = param1.data as TeamPKNoteInfo;
         homeTeamID = _loc2_.homeTeamID;
         awayTeamID = _loc2_.awayTeamID;
         PK_STATUS = _loc2_.event;
         if(PK_STATUS == START || PK_STATUS == OPEN_DOOR)
         {
            if(!inMap)
            {
               TeamPKManager.showIcon();
            }
         }
         if((PK_STATUS == START || PK_STATUS == OPEN_DOOR) && inMap && !isGetBuilding)
         {
            if(inMap)
            {
               getBuildingList();
               AutoShotManager.setup();
            }
         }
         DisplayUtil.removeForParent(waitPanel);
         if(PK_STATUS == START)
         {
            MainManager.actorInfo.teamPKInfo.homeTeamID = _loc2_.homeTeamID;
            if(_loc2_.homeTeamID != _loc2_.selfTeamID)
            {
               TEAM = AWAY;
               if(inMap)
               {
                  MapManager.styleID = MAP_ID;
                  MapManager.changeMap(_loc2_.homeTeamID,0,MapType.PK_TYPE);
               }
            }
            else
            {
               TEAM = HOME;
            }
            if(!isSendB)
            {
               isSendB = true;
               initBuildList();
               if(inMap)
               {
                  getTeamSituation();
               }
            }
         }
         else if(PK_STATUS == OPEN_DOOR && inMap)
         {
            dispatchEvent(new TeamPKEvent(TeamPKEvent.OPEN_DOOR));
         }
         else if(PK_STATUS == OVER)
         {
            removeIcon();
            PK_STATUS = 0;
         }
      }
      
      public static function levelMapInt() : void
      {
         TEAM = 0;
         teamPkSituationInfo = null;
      }
      
      public static function outTeamMap() : void
      {
         levelMapInt();
         gameOver();
      }
      
      public static function gameOver() : void
      {
         MapManager.DESTROY_SWITCH = true;
         buildingMap.clear();
         homeBuildingMap.clear();
         awayBuildingMap.clear();
         MapManager.changeMap(1);
      }
      
      private static function join() : void
      {
         MapManager.styleID = MAP_ID;
         MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchWithJoin);
         if(MainManager.actorInfo.teamInfo.id == MainManager.actorInfo.teamPKInfo.homeTeamID)
         {
            TEAM = HOME;
         }
         else
         {
            TEAM = AWAY;
         }
         MapManager.changeMap(MainManager.actorInfo.teamPKInfo.homeTeamID,0,MapType.PK_TYPE);
      }
      
      private static function onMapSwitchWithJoin(param1:MapEvent) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchWithJoin);
         SocketConnection.send(CommandID.TEAM_PK_JOIN);
      }
      
      private static function isMySelf(param1:BasePeoleModel) : Boolean
      {
         if(MainManager.actorInfo.userID == param1.info.userID)
         {
            return true;
         }
         return false;
      }
      
      private static function onPKJoin(param1:SocketEvent) : void
      {
         var data:TeamPKJoinInfo = null;
         var event:SocketEvent = param1;
         data = null;
         data = event.data as TeamPKJoinInfo;
         homeTeamID = data.homeTeamId;
         awayTeamID = data.awayTeamId;
         getEnamyTeamInfo();
         setTimeout(function():void
         {
            var _loc1_:TeamPkUserInfo = null;
            var _loc2_:BasePeoleModel = null;
            for each(_loc1_ in data.homeUserList)
            {
               _loc2_ = UserManager.getUserModel(_loc1_.uid);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.colorType = PeopleBloodBar.RED;
                  _loc2_.bloodBar.setHp(_loc1_.hp,_loc1_.maxHp);
                  if(isMySelf(_loc2_))
                  {
                     myMaxHp = _loc1_.maxHp;
                     myHp = _loc1_.hp;
                     TeamPKManager.dispatchEvent(new Event(INIT_HP));
                  }
                  if(_loc1_.isFreeze)
                  {
                  }
               }
               else
               {
                  noModelMaps.add(_loc1_.uid,_loc1_.uid);
               }
            }
            for each(_loc1_ in data.awayUserList)
            {
               _loc2_ = UserManager.getUserModel(_loc1_.uid);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.colorType = PeopleBloodBar.BLUE;
                  _loc2_.bloodBar.setHp(_loc1_.hp,_loc1_.maxHp);
                  if(isMySelf(_loc2_))
                  {
                     myMaxHp = _loc1_.maxHp;
                     myHp = _loc1_.hp;
                     TeamPKManager.dispatchEvent(new Event(INIT_HP));
                  }
                  if(_loc1_.isFreeze)
                  {
                  }
               }
               else
               {
                  noModelMaps.add(_loc1_.uid,_loc1_.uid);
               }
            }
         },1000);
      }
      
      private static function onSomeoneJoin(param1:SocketEvent) : void
      {
         var data:SomeoneJoinInfo = null;
         var event:SocketEvent = param1;
         data = null;
         data = event.data as SomeoneJoinInfo;
         setTimeout(function():void
         {
            var _loc1_:BasePeoleModel = null;
            if(data.userID != MainManager.actorID)
            {
               _loc1_ = UserManager.getUserModel(data.userID);
               if(!_loc1_)
               {
                  noModelMaps.add(data.userID,data.userID);
               }
               else
               {
                  if(_loc1_.info.teamInfo.id == homeTeamID)
                  {
                     _loc1_.bloodBar.colorType = PeopleBloodBar.RED;
                  }
                  else
                  {
                     _loc1_.bloodBar.colorType = PeopleBloodBar.BLUE;
                  }
                  _loc1_.bloodBar.setHp(data.hp,data.maxHp);
               }
            }
         },1000);
      }
      
      public static function petFight(param1:uint) : void
      {
         PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
         PetFightModel.mode = PetFightModel.SINGLE_MODE;
         SocketConnection.send(CommandID.TEAM_PK_PET_FIGHT,param1);
      }
      
      public static function shot(param1:uint, param2:uint, param3:uint) : void
      {
         SocketConnection.send(CommandID.TEAM_PK_SHOT,param1,param2,param3);
      }
      
      private static function beShotHandler(param1:SocketEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:BasePeoleModel = null;
         var _loc4_:PKArmModel = null;
         var _loc5_:SpriteBloodBar = null;
         var _loc6_:TeamPKBeShotInfo = param1.data as TeamPKBeShotInfo;
         var _loc7_:ShooterInfo = _loc6_.shooter();
         var _loc8_:ShooterInfo = _loc6_.beShooer();
         switch(_loc6_.shotType)
         {
            case TeamPKBeShotInfo.BUILDING_TO_PLAYER:
               _loc2_ = UserManager.getUserModel(_loc8_.userID);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.setHp(_loc8_.leftHp,_loc8_.maxHp,_loc6_.damage);
               }
               _loc5_ = new SpriteBloodBar(ShotBehaviorManager.getMovieClip("pk_blood_bar"));
               _loc5_.setHp(_loc7_.leftHp,_loc7_.maxHp);
               _loc4_ = buildingMap.getValue(_loc7_.buyTime);
               _loc4_.additive = [_loc5_];
               if(_loc7_.leftHp == 0)
               {
                  _loc4_.freeze();
               }
               _loc3_ = _loc2_;
               _loc4_.shot(_loc2_);
               if(TEAM == HOME)
               {
                  if(awayBuildingMap.containsKey(_loc7_.buyTime) && _loc7_.leftHp == 0)
                  {
                     win();
                  }
                  break;
               }
               if(homeBuildingMap.containsKey(_loc7_.buyTime) && _loc7_.leftHp == 0)
               {
                  win();
               }
               break;
            case TeamPKBeShotInfo.PLAYER_TO_BUILDING:
               _loc5_ = new SpriteBloodBar(ShotBehaviorManager.getMovieClip("pk_blood_bar"));
               _loc4_ = buildingMap.getValue(_loc8_.buyTime);
               _loc4_.additive = [_loc5_];
               _loc5_.setHp(_loc8_.leftHp,_loc8_.maxHp,_loc6_.damage);
               if(_loc8_.leftHp == 0)
               {
                  _loc4_.freeze();
               }
               _loc2_ = UserManager.getUserModel(_loc7_.userID);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.setHp(_loc7_.leftHp,_loc7_.maxHp);
               }
               if(TEAM == HOME)
               {
                  if(awayBuildingMap.containsKey(_loc8_.buyTime) && _loc8_.leftHp == 0)
                  {
                     win();
                  }
                  break;
               }
               if(homeBuildingMap.containsKey(_loc8_.buyTime) && _loc8_.leftHp == 0)
               {
                  win();
               }
               break;
            case TeamPKBeShotInfo.PLAYER_TO_PLAYER:
               _loc2_ = UserManager.getUserModel(_loc8_.userID);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.setHp(_loc8_.leftHp,_loc8_.maxHp,_loc6_.damage);
               }
               _loc3_ = _loc2_;
               _loc2_ = UserManager.getUserModel(_loc7_.userID);
               if(Boolean(_loc2_))
               {
                  _loc2_.bloodBar.setHp(_loc7_.leftHp,_loc7_.maxHp);
               }
         }
         if(!_loc3_)
         {
            return;
         }
         if(isMySelf(_loc3_))
         {
            myHp = _loc8_.leftHp;
            TeamPKManager.dispatchEvent(new Event(INIT_HP));
         }
      }
      
      public static function updateDistance(param1:Array) : void
      {
         var _loc2_:PKArmModel = null;
         var _loc3_:ByteArray = new ByteArray();
         var _loc4_:uint = param1.length;
         _loc3_.writeUnsignedInt(_loc4_);
         for each(_loc2_ in param1)
         {
            _loc3_.writeUnsignedInt(_loc2_.info.buyTime);
            _loc3_.writeUnsignedInt(Point.distance(_loc2_.info.pos,MainManager.actorModel.pos));
         }
         SocketConnection.send(CommandID.TEAM_PK_REFRESH_DISTANCE,_loc3_);
      }
      
      public static function win() : void
      {
         SocketConnection.send(CommandID.TEAM_PK_WIN);
      }
      
      public static function getBuildingList() : void
      {
         SocketConnection.send(CommandID.TEAM_PK_GET_BUILDING_INFO);
      }
      
      private static function onGetBuildingInfo(param1:SocketEvent) : void
      {
         MapManager.DESTROY_SWITCH = false;
         var _loc2_:TeamPKBuildingListInfo = param1.data as TeamPKBuildingListInfo;
         homeList = _loc2_.homeList;
         awayList = _loc2_.awayList;
         TeamPKManager.dispatchEvent(new TeamPKEvent(TeamPKEvent.GET_BUILDING_LIST));
         getEnamyTeamInfo();
      }
      
      public static function get homeBuildinList() : Array
      {
         return homeList;
      }
      
      public static function get awayBuildinList() : Array
      {
         return awayList;
      }
      
      private static function onFreeze(param1:SocketEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:TeamPKFreezeInfo = param1.data as TeamPKFreezeInfo;
         var _loc4_:uint = _loc3_.flag;
         var _loc5_:uint = _loc3_.uid;
         var _loc6_:BasePeoleModel = UserManager.getUserModel(_loc5_);
         if(!_loc6_)
         {
            freezeIDs.push(_loc3_);
            return;
         }
         if(_loc4_ == 1)
         {
            _loc6_.additive = [new SpriteFreeze()];
            _loc2_ = MapConfig.getMapPeopleXY(0,homeTeamID);
            if(_loc6_.info.teamInfo.id == homeTeamID)
            {
               _loc6_.x = _loc2_.x;
               _loc6_.y = _loc2_.y;
            }
            else
            {
               _loc6_.x = _loc2_.x + REDX;
               _loc2_.x += REDX;
               _loc6_.y = _loc2_.y;
            }
            if(_loc5_ == MainManager.actorID)
            {
               if(TEAM == HOME)
               {
                  LevelManager.moveToLeft();
               }
               else
               {
                  LevelManager.moveToRight();
               }
               _loc6_.walkAction(_loc2_);
               MouseController.removeMouseEvent();
               TeamPKManager.dispatchEvent(new TeamPKEvent(TeamPKEvent.CLOSE_TOOL));
            }
         }
         else
         {
            _loc6_.skeleton.getBodyMC().filters = [];
            if(_loc5_ == MainManager.actorID)
            {
               myHp = TeamPKManager.myMaxHp;
               _loc6_.bloodBar.setHp(myHp,myHp);
               dispatchEvent(new Event(INIT_HP));
               MouseController.addMouseEvent();
               TeamPKManager.dispatchEvent(new TeamPKEvent(TeamPKEvent.OPEN_TOOL));
            }
         }
      }
      
      private static function onUseShield(param1:SocketEvent) : void
      {
         var _loc2_:SuperNonoShieldInfo = param1.data as SuperNonoShieldInfo;
         if(_loc2_.uid == 0)
         {
            return;
         }
         var _loc3_:BasePeoleModel = UserManager.getUserModel(_loc2_.uid);
         _loc3_.showNonoShield(_loc2_.leftTime);
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

