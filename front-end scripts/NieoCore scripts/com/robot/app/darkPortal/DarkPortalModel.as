package com.robot.app.darkPortal
{
   import com.robot.app.fightLevel.FightPetBagController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class DarkPortalModel
   {
      
      private static var _curBossId:uint;
      
      private static var _curDoor:uint;
      
      private static var _doorHanlder:Function;
      
      private static var _fiSucHandler:Function;
      
      private static var _panel:AppModel;
      
      private static var _curFun:Function;
      
      private static var _petBtn:SimpleButton;
      
      public static var doorIndex:uint = 0;
      
      public function DarkPortalModel()
      {
         super();
      }
      
      public static function get curDoor() : uint
      {
         return _curDoor;
      }
      
      public static function set curDoor(param1:uint) : void
      {
         _curDoor = param1;
      }
      
      public static function get curBossId() : uint
      {
         return _curBossId;
      }
      
      public static function set curBossId(param1:uint) : void
      {
         _curBossId = param1;
      }
      
      public static function enterDarkProtal(param1:uint, param2:Function = null, param3:uint = 0) : void
      {
         doorIndex = param3;
         _curDoor = param1;
         _doorHanlder = param2;
         SocketConnection.addCmdListener(CommandID.OPEN_DARKPORTAL,onSucHandler);
         SocketConnection.send(CommandID.OPEN_DARKPORTAL,param1);
      }
      
      private static function onSucHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.OPEN_DARKPORTAL,onSucHandler);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         _curBossId = _loc3_;
         if(_doorHanlder != null)
         {
            _doorHanlder();
            _doorHanlder = null;
         }
         enterMap();
      }
      
      public static function enterMap() : void
      {
         var _loc1_:* = 502;
         var _loc2_:uint = uint(_curDoor + 1);
         if(_loc2_ > 6)
         {
            if(_loc2_ % 6 == 0)
            {
               _loc1_ += _loc2_ / 6;
            }
            else
            {
               _loc1_ += uint(_loc2_ / 6) + 1;
            }
         }
         else
         {
            _loc1_++;
         }
         MapManager.changeLocalMap(_loc1_);
      }
      
      public static function fightDarkProtal(param1:Function = null) : void
      {
         _fiSucHandler = param1;
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         SocketConnection.addCmdListener(CommandID.FIGHT_DARKPORTAL,onFiHandler);
         SocketConnection.send(CommandID.FIGHT_DARKPORTAL);
      }
      
      private static function onFiHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.FIGHT_DARKPORTAL,onFiHandler);
         if(_fiSucHandler != null)
         {
            _fiSucHandler();
            _fiSucHandler = null;
         }
      }
      
      public static function leaveDarkProtal(param1:Function = null) : void
      {
         var func:Function = param1;
         SocketConnection.addCmdListener(CommandID.LEAVE_DARKPORTAL,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.LEAVE_DARKPORTAL,arguments.callee);
            if(func != null)
            {
               func();
            }
            MapManager.changeMap(110);
         });
         SocketConnection.send(CommandID.LEAVE_DARKPORTAL);
      }
      
      public static function showDoor(param1:uint, param2:Function = null) : void
      {
         destroyPanel();
         _curFun = param2;
         _panel = new AppModel(ClientConfig.getAppModule("DarkDoorChoicePanel_" + param1),"正在打开暗黑之门");
         _panel.setup();
         _panel.sharedEvents.addEventListener(Event.CLOSE,onCloseHandler);
         _panel.show();
      }
      
      private static function onCloseHandler(param1:Event) : void
      {
         if(_curFun != null)
         {
            _curFun();
            _curFun = null;
         }
      }
      
      public static function destroyPanel() : void
      {
         if(Boolean(_panel))
         {
            _panel.sharedEvents.removeEventListener(Event.CLOSE,onCloseHandler);
            _panel.destroy();
            _panel = null;
         }
      }
      
      public static function destroy() : void
      {
         destroyPanel();
         SocketConnection.removeCmdListener(CommandID.OPEN_DARKPORTAL,onSucHandler);
         SocketConnection.removeCmdListener(CommandID.FIGHT_DARKPORTAL,onFiHandler);
         onCloseHandler(null);
      }
      
      public static function showPetEnrichBlood() : void
      {
         setTimeout(function():void
         {
            _petBtn = MapManager.currentMap.controlLevel["petMc"];
            _petBtn.addEventListener(MouseEvent.CLICK,onClickHandler);
            ToolTipManager.add(_petBtn,"精灵背包");
         },200);
      }
      
      private static function onClickHandler(param1:MouseEvent) : void
      {
         FightPetBagController.show();
      }
      
      public static function des() : void
      {
         if(Boolean(_petBtn))
         {
            ToolTipManager.remove(_petBtn);
            _petBtn.addEventListener(MouseEvent.CLICK,onClickHandler);
            _petBtn = null;
         }
         FightPetBagController.destroy();
      }
   }
}

