package com.robot.core.controller
{
   import com.robot.core.CommandID;
   import com.robot.core.aticon.FlyAction;
   import com.robot.core.aticon.WalkAction;
   import com.robot.core.event.ArmEvent;
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.manager.ArmManager;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.HeadquarterManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.map.MapTransEffect;
   import com.robot.core.manager.map.MapType;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.manager.map.config.MapProcessConfig;
   import com.robot.core.mode.MapModel;
   import com.robot.core.mode.PeopleModel;
   import com.robot.core.net.ConnectionType;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.teamInstallation.ShowTeamLogo;
   import com.robot.core.teamPK.TeamPKManager;
   import com.robot.core.teamPK.shotActive.PKInteractiveAction;
   import com.robot.core.utils.Direction;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.taomee.algo.AStar;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapController
   {
      
      private static var _isReMap:Boolean = false;
      
      private static var _isChange:Boolean = false;
      
      private static var _isLogin:Boolean = true;
      
      private static var _isSwitching:Boolean = false;
      
      private var _mapModel:MapModel;
      
      private var _newMapID:uint;
      
      private var _dir:int = 0;
      
      private var _roomCol:RoomController;
      
      private var _isShowLoading:Boolean = true;
      
      private var _mapType:uint;
      
      private var _tempStyleID:uint;
      
      public var isChangeLocal:Boolean = false;
      
      public function MapController()
      {
         super();
      }
      
      public static function get isReMap() : Boolean
      {
         return _isReMap;
      }
      
      public function get newMapID() : uint
      {
         return this._newMapID;
      }
      
      public function changeLocalMap(param1:uint, param2:uint = 0) : void
      {
         this.isChangeLocal = true;
         this._dir = param2;
         this._newMapID = param1;
         this._mapType = 0;
         this._tempStyleID = 0;
         _isChange = true;
         _isReMap = false;
         this.startSwitch();
      }
      
      public function closeChange() : void
      {
         this._mapModel.closeChange();
      }
      
      public function changeMap(param1:uint, param2:int = 0, param3:uint = 0) : void
      {
         this.isChangeLocal = false;
         if(_isSwitching)
         {
            return;
         }
         if(!_isLogin)
         {
            if(param1 == MainManager.actorInfo.mapID || param1 == this._newMapID)
            {
               if(param3 == MapManager.type || param3 == this._mapType)
               {
                  if(param3 <= MapManager.TYPE_MAX && param1 != MapManager.TOWER_MAP && param1 != MapManager.FRESH_TRIALS)
                  {
                     return;
                  }
               }
            }
            MouseController.removeMouseEvent();
         }
         this._dir = param2;
         this._newMapID = param1;
         this._mapType = param3;
         this._tempStyleID = MapManager.styleID;
         _isChange = true;
         _isReMap = false;
         this.startSwitch();
      }
      
      public function refMap(param1:Boolean = true) : void
      {
         if(_isSwitching)
         {
            return;
         }
         this._isShowLoading = param1;
         _isChange = true;
         _isReMap = true;
         this.startSwitch();
      }
      
      public function destroy() : void
      {
         MapManager.isInMap = false;
         MainManager.actorModel.stop();
         MainManager.actorModel.aimatStateManager.clear();
         MapConfig.clear();
         MapProcessConfig.destroy();
         if(Boolean(MapManager.currentMap))
         {
            MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_DESTROY,MapManager.currentMap));
            MapManager.currentMap.destroy();
            MapManager.currentMap = null;
         }
      }
      
      private function startSwitch() : void
      {
         CameraController.clear();
         _isSwitching = true;
         LevelManager.closeMouseEvent();
         if(this._newMapID > MapManager.ID_MAX)
         {
            switch(this._mapType)
            {
               case MapType.HOOM:
                  FitmentManager.addEventListener(FitmentEvent.USED_LIST,function(param1:FitmentEvent):void
                  {
                     FitmentManager.removeEventListener(FitmentEvent.USED_LIST,arguments.callee);
                     _startSwitch(MapManager.styleID);
                  });
                  FitmentManager.getUsedInfo(this._newMapID);
                  break;
               case MapType.CAMP:
                  ArmManager.addEventListener(ArmEvent.USED_LIST,function(param1:ArmEvent):void
                  {
                     ArmManager.removeEventListener(ArmEvent.USED_LIST,arguments.callee);
                     _startSwitch(MapManager.styleID);
                  });
                  ArmManager.getUsedInfoForServer(this._newMapID);
                  break;
               case MapType.HEAD:
                  HeadquarterManager.addEventListener(FitmentEvent.USED_LIST,function(param1:FitmentEvent):void
                  {
                     HeadquarterManager.removeEventListener(FitmentEvent.USED_LIST,arguments.callee);
                     _startSwitch(MapManager.styleID);
                  });
                  HeadquarterManager.getUsedInfo(this._newMapID);
                  break;
               default:
                  this._startSwitch();
            }
         }
         else
         {
            this._startSwitch();
         }
      }
      
      private function _startSwitch(param1:uint = 0) : void
      {
         MapManager.addEventListener(MapEvent.MAP_INIT,this.onMapInit);
         MapManager.addEventListener(ErrorEvent.ERROR,this.onMapFail);
         MapManager.addEventListener(MapEvent.MAP_LOADER_CLOSE,this.onMapFail);
         this._mapModel = new MapModel(this._newMapID,!_isLogin,this._isShowLoading);
         MapManager.initPos = MapConfig.getMapPeopleXY(MainManager.actorInfo.mapID,this._newMapID);
         ResourceManager.stop();
      }
      
      private function comeInMap() : void
      {
         MainManager.actorModel.showClothLight(true);
         if(this._newMapID == MapManager.FRESH_TRIALS || this._newMapID == MapManager.TOWER_MAP || this.isChangeLocal)
         {
            this.initMapFunction(false);
            return;
         }
         // Always use MAIN connection type - no server jumping for home maps
         // Home maps (mapID > ID_MAX) are now treated like normal maps
         MapManager.type = ConnectionType.MAIN;
         SocketConnection.send(CommandID.ENTER_MAP,this._mapType,this._newMapID,MapManager.initPos.x,MapManager.initPos.y);
      }
      
      private function initMapFunction(param1:Boolean = true) : void
      {
         var mte:MapTransEffect = null;
         var isGetUser:Boolean = param1;
         var pinfo:PetShowInfo = null;
         MapManager.removeEventListener(MapEvent.MAP_LOADER_CLOSE,this.onMapFail);
         LevelManager.openMouseEvent();
         ResourceManager.play();
         mte = new MapTransEffect(this._mapModel,this._dir);
         mte.addEventListener(MapEvent.MAP_EFFECT_COMPLETE,function(param1:MapEvent):void
         {
            DisplayUtil.removeAllChild(LevelManager.appLevel);
            DisplayUtil.removeAllChild(LevelManager.mapLevel);
            LevelManager.mapLevel.addChild(_mapModel.root);
         });
         mte.star();
         this.destroy();
         MapManager.isInMap = true;
         LevelManager.mapScroll = false;
         MapManager.prevMapID = MainManager.actorInfo.mapID;
         MainManager.actorInfo.mapType = this._mapType;
         MainManager.actorInfo.mapID = this._newMapID;
         MapManager.currentMap = this._mapModel;
         AStar.init(MapManager.currentMap,1500);
         MapConfig.configMap(MapManager.getResMapID(this._newMapID));
         MapManager.currentMap.depthLevel.addChild(MainManager.actorModel.sprite);
         if(!_isReMap)
         {
            MainManager.actorModel.pos = MapManager.initPos;
         }
         MapProcessConfig.configMap(MapManager.getResMapID(this._newMapID),this._mapType);
         if(MapManager.currentMap.id == 460)
         {
            CameraController.setup(MapManager.currentMap,MainManager.actorModel,new Rectangle(0,0,1920,560));
         }
         if(MapManager.currentMap.id == 461)
         {
            CameraController.setup(MapManager.currentMap,MainManager.actorModel,new Rectangle(0,0,1450,1200));
         }
         MainManager.actorModel.direction = Direction.DOWN;
         if(Boolean(PetManager.showInfo))
         {
            pinfo = new PetShowInfo();
            pinfo.catchTime = PetManager.showInfo.catchTime;
            pinfo.petID = PetManager.showInfo.id;
            pinfo.userID = MainManager.actorID;
            pinfo.dv = PetManager.showInfo.dv;
            pinfo.skinID = PetManager.showInfo.skinID;
            MainManager.actorModel.showPet(pinfo);
         }
         DepthManager.swapDepthAll(MapManager.currentMap.depthLevel);
         MouseController.addMouseEvent();
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_SWITCH_COMPLETE,MapManager.currentMap));
         this._mapModel.closeLoading();
         _isSwitching = false;
         if(MapManager.currentMap.width > MainManager.getStageWidth())
         {
            LevelManager.mapScroll = true;
         }
         if(isGetUser && this._newMapID != 515)
         {
            SocketConnection.send(CommandID.LIST_MAP_PLAYER);
         }
         MainManager.actorModel.showClothLight();
      }
      
      private function onLeaveMap(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         _loc2_.position = 0;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         if(this.isChangeLocal)
         {
            return;
         }
         if(_loc3_ == MainManager.actorID)
         {
            if(_isChange)
            {
               _isChange = false;
               this.comeInMap();
            }
         }
         else
         {
            if(MapManager.currentMap == null)
            {
               return;
            }
            MapManager.currentMap.removeUser(_loc3_);
         }
         MainManager.actorModel.delProtectMC();
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.CREATED_MAP_USER));
      }
      
      private function onEnterMap(param1:SocketEvent) : void
      {
         var _loc2_:PeopleModel = null;
         if(this._newMapID == MapManager.TOWER_MAP)
         {
            MapManager.changeMap(108);
            return;
         }
         if(this._newMapID == MapManager.FRESH_TRIALS)
         {
            MapManager.changeMap(101);
            return;
         }
         if(this.isChangeLocal)
         {
            return;
         }
         var _loc3_:UserInfo = new UserInfo();
         UserInfo.setForPeoleInfo(_loc3_,param1.data as IDataInput);
         _loc3_.serverID = MainManager.serverID;
         if(_loc3_.userID == MainManager.actorID)
         {
            if(_isReMap)
            {
               MainManager.actorModel.pos = _loc3_.pos;
            }
            MainManager.upDateForPeoleInfo(_loc3_);
            this.initMapFunction();
         }
         else
         {
            if(MapManager.currentMap == null)
            {
               return;
            }
            _loc2_ = new PeopleModel(_loc3_);
            if(_loc3_.actionType == 0)
            {
               _loc2_.walk = new WalkAction();
            }
            else
            {
               _loc2_.walk = new FlyAction(_loc2_);
            }
            if(MainManager.actorInfo.mapType == MapType.PK_TYPE)
            {
               if(_loc3_.teamInfo.id != MainManager.actorInfo.mapID)
               {
                  _loc2_.x = _loc3_.pos.x + TeamPKManager.REDX;
                  _loc2_.additiveInfo.info = TeamPKManager.AWAY;
               }
               else
               {
                  _loc2_.additiveInfo.info = TeamPKManager.HOME;
               }
               _loc2_.interactiveAction = new PKInteractiveAction(_loc2_);
            }
            MapManager.currentMap.addUser(_loc2_);
            if(_loc3_.teamInfo.isShow)
            {
               ShowTeamLogo.showLogo(_loc2_);
            }
         }
         MainManager.actorModel.delProtectMC();
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.CREATED_MAP_USER));
      }
      
      private function onMapInit(param1:Event) : void
      {
         MapManager.removeEventListener(MapEvent.MAP_INIT,this.onMapInit);
         MapManager.removeEventListener(ErrorEvent.ERROR,this.onMapFail);
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_SWITCH_OPEN,MapManager.currentMap));
         if(_isLogin)
         {
            _isLogin = false;
            this.initMapFunction();
            SocketConnection.addCmdListener(CommandID.ENTER_MAP,this.onEnterMap);
            SocketConnection.addCmdListener(CommandID.LEAVE_MAP,this.onLeaveMap);
            SocketConnection.addCmdListener(CommandID.ON_MAP_SWITCH,this.onMapOnSwitch);
         }
         else if(MapManager.isInMap)
         {
            // Unified map switching - home maps (mapID > ID_MAX) use same flow as normal maps
            // No separate room server connection needed
            if(this._newMapID == MapManager.FRESH_TRIALS || this._newMapID == MapManager.TOWER_MAP || this.isChangeLocal)
            {
               this.comeInMap();
               return;
            }
            SocketConnection.send(CommandID.LEAVE_MAP);
         }
         else
         {
            this.initMapFunction(this._newMapID != 500);
         }
      }
      
      private function onMapOnSwitch(param1:SocketEvent) : void
      {
         if(Boolean(this._mapModel))
         {
            this.onMapFail(null);
         }
      }
      
      private function onMapFail(param1:Event) : void
      {
         this._mapModel.closeLoading();
         this._mapType = MainManager.actorInfo.mapType;
         this._newMapID = MainManager.actorInfo.mapID;
         MapManager.styleID = this._tempStyleID;
         LevelManager.openMouseEvent();
         MapManager.removeEventListener(MapEvent.MAP_INIT,this.onMapInit);
         MapManager.removeEventListener(ErrorEvent.ERROR,this.onMapFail);
         MapManager.removeEventListener(MapEvent.MAP_LOADER_CLOSE,this.onMapFail);
         MouseController.addMouseEvent();
         _isSwitching = false;
         MapManager.dispatchEvent(new MapEvent(MapEvent.MAP_ERROR));
      }
      
      private function onRoomAddres(param1:RobotEvent) : void
      {
         this._roomCol.removeEventListener(RobotEvent.GET_ROOM_ADDRES,this.onRoomAddres);
         SocketConnection.send(CommandID.LEAVE_MAP);
      }
      
      private function onRoomConnect(param1:Event) : void
      {
         this._roomCol.removeEventListener(Event.CONNECT,this.onRoomConnect);
         this._roomCol.inRoom(this._mapType,MapManager.initPos.x,MapManager.initPos.y);
      }
      
      private function onRoomLeave(param1:RobotEvent) : void
      {
         if(MapManager.type == ConnectionType.ROOM)
         {
            this._roomCol.addEventListener(Event.CONNECT,this.onRoomConnect);
            this._roomCol.connect();
         }
      }
      
      private function onRoomError(param1:ErrorEvent) : void
      {
         this._roomCol.removeEventListener(Event.CONNECT,this.onRoomConnect);
         this._roomCol.removeEventListener(ErrorEvent.ERROR,this.onRoomError);
         if(Boolean(this._mapModel))
         {
            this._mapModel.closeLoading();
         }
         MapManager.styleID = this._tempStyleID;
         this._mapType = MainManager.actorInfo.mapType;
         this._newMapID = MainManager.actorInfo.mapID;
         _isReMap = true;
         RoomController.isClose = true;
         this.startSwitch();
      }
   }
}

