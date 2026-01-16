package com.robot.app.sceneInteraction
{
   import com.robot.app.bag.BagClothPreview;
   import com.robot.app.info.ArenaInfo;
   import com.robot.core.CommandID;
   import com.robot.core.controller.MouseController;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.event.UserEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.UserInfoManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.ClothPreview;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.utils.Direction;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class ArenaController
   {
      
      private static var _instance:ArenaController;
      
      private static const UP_POS:Point = new Point(420,120);
      
      private static const DOWN_POS:Point = new Point(410,310);
      
      private var _oldHostID:uint;
      
      private var _oldChallengerID:uint;
      
      private var _currHostID:uint;
      
      private var _flag:uint;
      
      private var _arenaInfoPanel:MovieClip;
      
      private var _showMC:Sprite;
      
      private var _compose:BagClothPreview;
      
      public function ArenaController()
      {
         super();
      }
      
      public static function getInstance() : ArenaController
      {
         if(_instance == null)
         {
            _instance = new ArenaController();
            MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
            EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onFightOver);
            SocketConnection.addCmdListener(CommandID.ARENA_OWENR_OUT,onOwenrOut);
         }
         return _instance;
      }
      
      private static function onMapSwitchComplete(param1:MapEvent) : void
      {
         if(Boolean(_instance))
         {
            if(MapManager.prevMapID == 102)
            {
               if(MapManager.getMapController().newMapID != 102)
               {
                  MapManager.removeEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapSwitchComplete);
                  EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onFightOver);
                  SocketConnection.removeCmdListener(CommandID.ARENA_OWENR_OUT,onOwenrOut);
                  _instance.destroy();
                  _instance = null;
               }
            }
         }
      }
      
      private static function onFightOver(param1:PetFightEvent) : void
      {
         var _loc2_:FightOverInfo = param1.dataObj as FightOverInfo;
         if(_loc2_.winnerID == MainManager.actorID)
         {
            SocketConnection.send(CommandID.ARENA_OWENR_ACCE);
         }
      }
      
      private static function onOwenrOut(param1:SocketEvent) : void
      {
         Alarm.show("很遗憾，你没有及时回到擂台应战，失去了擂主位置，你可以再次挑战，夺回擂主的资格。");
      }
      
      public function setup(param1:MovieClip) : void
      {
         this._arenaInfoPanel = param1;
         this._arenaInfoPanel.mouseChildren = false;
         this._arenaInfoPanel.mouseEnabled = false;
         this._arenaInfoPanel["colorMc"].gotoAndStop(1);
         SocketConnection.addCmdListener(CommandID.ARENA_GET_INFO,this.onArenaInfo);
         SocketConnection.send(CommandID.ARENA_GET_INFO);
         MapManager.addEventListener(MapEvent.MAP_ERROR,this.onMapError);
      }
      
      public function destroy() : void
      {
         SocketConnection.removeCmdListener(CommandID.ARENA_GET_INFO,this.onArenaInfo);
         MapManager.removeEventListener(MapEvent.MAP_ERROR,this.onMapError);
         this._oldHostID = 0;
         this._oldChallengerID = 0;
         this._currHostID = 0;
         this._compose = null;
         this._showMC = null;
         this._arenaInfoPanel = null;
      }
      
      public function strat() : void
      {
         if(this._flag == 1)
         {
            Alert.show("确定要挑战擂主吗？",function():void
            {
               PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
               PetFightModel.mode = PetFightModel.SINGLE_MODE;
               SocketConnection.send(CommandID.ARENA_FIGHT_OWENR);
            });
         }
         else if(this._flag == 0)
         {
            PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
            PetFightModel.mode = PetFightModel.SINGLE_MODE;
            SocketConnection.send(CommandID.ARENA_SET_OWENR);
         }
         else if(this._flag == 2)
         {
            Alarm.show("擂台赛战斗已经开始,等会再挑战吧！");
         }
      }
      
      public function figth() : void
      {
         SocketConnection.removeCmdListener(CommandID.ARENA_GET_INFO,this.onArenaInfo);
         MapManager.removeEventListener(MapEvent.MAP_ERROR,this.onMapError);
         if(Boolean(this._showMC))
         {
            DisplayUtil.removeForParent(this._showMC);
            EventManager.removeEventListener(UserEvent.INFO_CHANGE,this.onUserInfo);
         }
      }
      
      private function setUserMove(param1:uint, param2:Boolean = false) : void
      {
         var _loc4_:BasePeoleModel = null;
         var _loc3_:Point = null;
         _loc4_ = null;
         if(Boolean(param1))
         {
            if(param2)
            {
               _loc3_ = UP_POS;
            }
            else
            {
               _loc3_ = DOWN_POS;
            }
            if(param1 == MainManager.actorID)
            {
               MainManager.actorModel.stop();
               MainManager.actorModel.pos = _loc3_;
               MainManager.actorModel.direction = Direction.DOWN;
               if(Boolean(MainManager.actorModel.pet))
               {
                  MainManager.actorModel.pet.pos = _loc3_.add(new Point(40,5));
                  MainManager.actorModel.pet.direction = Direction.DOWN;
               }
               if(param2)
               {
                  MouseController.removeMouseEvent();
                  MapManager.currentMap.controlLevel.mouseChildren = false;
                  MapManager.currentMap.btnLevel.mouseChildren = false;
                  MapManager.currentMap.spaceLevel.addEventListener(MouseEvent.MOUSE_UP,this.onMouseDown);
               }
               else
               {
                  MapManager.currentMap.spaceLevel.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseDown);
                  MapManager.currentMap.controlLevel.mouseChildren = true;
                  MapManager.currentMap.btnLevel.mouseChildren = true;
                  MouseController.addMouseEvent();
               }
            }
            else
            {
               _loc4_ = UserManager.getUserModel(param1);
               if(Boolean(_loc4_))
               {
                  _loc4_.stop();
                  _loc4_.pos = _loc3_;
                  _loc4_.direction = Direction.DOWN;
                  if(Boolean(_loc4_.pet))
                  {
                     _loc4_.pet.pos = _loc3_.add(new Point(40,5));
                     _loc4_.pet.direction = Direction.DOWN;
                  }
               }
            }
         }
      }
      
      private function setArenaEmpty(param1:uint, param2:uint) : void
      {
         this.setUserMove(param1);
         this.setUserMove(param2);
         this._oldChallengerID = 0;
         this._oldHostID = 0;
         this._arenaInfoPanel["colorMc"].gotoAndStop(1);
         this._arenaInfoPanel["countTxt"].text = "0";
         this._arenaInfoPanel["nameTxt"].text = "";
         if(Boolean(this._showMC))
         {
            DisplayUtil.removeForParent(this._showMC);
            EventManager.removeEventListener(UserEvent.INFO_CHANGE,this.onUserInfo);
         }
      }
      
      private function setArenaInfo(param1:ArenaInfo) : void
      {
         var info:ArenaInfo = param1;
         this._arenaInfoPanel["countTxt"].text = info.hostWins.toString();
         this._arenaInfoPanel["nameTxt"].text = info.hostNick.toString() + "\n(" + info.hostID.toString() + ")";
         if(this._showMC == null)
         {
            this._showMC = UIManager.getSprite("ComposeMC");
            this._showMC.mouseChildren = false;
            this._showMC.mouseEnabled = false;
            this._showMC.scaleX = 0.23;
            this._showMC.scaleY = 0.23;
            this._showMC.x = 14;
            this._showMC.y = 35;
            this._compose = new BagClothPreview(this._showMC,null,ClothPreview.MODEL_SHOW);
         }
         if(!DisplayUtil.hasParent(this._showMC))
         {
            EventManager.addEventListener(UserEvent.INFO_CHANGE,this.onUserInfo);
            this._arenaInfoPanel.addChild(this._showMC);
         }
         UserInfoManager.getInfo(info.hostID,function(param1:UserInfo):void
         {
            _compose.changeColor(param1.color);
            _compose.showCloths(param1.clothes);
            _compose.showDoodle(param1.texture);
         });
      }
      
      private function onArenaInfo(param1:SocketEvent) : void
      {
         var _loc2_:ArenaInfo = param1.data as ArenaInfo;
         this._flag = _loc2_.flag;
         this._currHostID = _loc2_.hostID;
         if(_loc2_.flag == 0)
         {
            this.setArenaEmpty(this._oldHostID,this._oldChallengerID);
            return;
         }
         if(_loc2_.flag == 1)
         {
            this._arenaInfoPanel["colorMc"].gotoAndStop(1);
         }
         else if(_loc2_.flag == 2)
         {
            this._arenaInfoPanel["colorMc"].gotoAndStop(2);
         }
         if(Boolean(this._oldHostID) && Boolean(this._oldChallengerID))
         {
            if(this._oldHostID == _loc2_.hostID)
            {
               if(this._oldHostID == MainManager.actorID)
               {
                  Alarm.show("你赢得了这次对战的胜利，你现在的连胜次数是" + TextFormatUtil.getRedTxt(_loc2_.hostWins.toString()) + "次。");
               }
               if(this._oldChallengerID == MainManager.actorID)
               {
                  Alarm.show("很遗憾，这次的战斗你没有获胜，你可以再次挑战。");
               }
            }
            else
            {
               if(this._oldHostID == MainManager.actorID)
               {
                  Alarm.show("很遗憾，这次的战斗你没有获胜，你可以再次挑战，夺回擂主的资格。");
               }
               if(this._oldChallengerID == _loc2_.hostID)
               {
                  if(_loc2_.hostID == MainManager.actorID)
                  {
                     Alarm.show("恭喜你获得了这次挑战的胜利，现在你是擂主了，接受其他赛尔的挑战，看看你能连胜多少次。");
                  }
               }
            }
         }
         this.setUserMove(_loc2_.hostID,true);
         if(Boolean(this._oldHostID))
         {
            if(this._oldHostID == _loc2_.hostID)
            {
               this.setUserMove(this._oldChallengerID);
            }
            else
            {
               this.setUserMove(this._oldHostID);
            }
         }
         this.setArenaInfo(_loc2_);
         this._oldHostID = _loc2_.hostID;
         this._oldChallengerID = _loc2_.challengerID;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         Alert.show("你确定要放弃擂台挑战吗？",function():void
         {
            SocketConnection.send(CommandID.ARENA_UPFIGHT);
         });
      }
      
      private function onUserInfo(param1:UserEvent) : void
      {
         var _loc2_:UserInfo = param1.userInfo;
         if(_loc2_.userID == this._currHostID)
         {
            this._arenaInfoPanel["nameTxt"].text = _loc2_.nick.toString() + "\n(" + _loc2_.userID.toString() + ")";
            this._compose.changeColor(_loc2_.color);
            this._compose.showCloths(_loc2_.clothes);
            this._compose.showDoodle(_loc2_.texture);
         }
      }
      
      private function onMapError(param1:MapEvent) : void
      {
         MouseController.removeMouseEvent();
         MapManager.currentMap.controlLevel.mouseChildren = false;
         MapManager.currentMap.btnLevel.mouseChildren = false;
         Alarm.show("你目前不能离开此场景！");
      }
   }
}

