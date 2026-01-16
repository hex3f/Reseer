package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.SoundManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.GamePlatformEvent;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.MapEvent;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.taomee.events.SocketEvent;
   
   public class GamePlatformManager
   {
      
      private static var currentGame:AppModel;
      
      private static var _name:String;
      
      private static var paramObj:Object;
      
      private static var _instance:EventDispatcher;
      
      private static var currentName:String = "";
      
      private static var _isOnline:Boolean = false;
      
      private static var isConnecting:Boolean = false;
      
      public function GamePlatformManager()
      {
         super();
      }
      
      private static function setup() : void
      {
         MapManager.addEventListener(MapEvent.MAP_SWITCH_OPEN,onSwitchOpen);
      }
      
      public static function win() : void
      {
         dispatchEvent(new GamePlatformEvent(GamePlatformEvent.GAME_WIN));
      }
      
      public static function lost() : void
      {
         dispatchEvent(new GamePlatformEvent(GamePlatformEvent.GAME_LOST));
      }
      
      private static function onSwitchOpen(param1:MapEvent) : void
      {
         if(Boolean(currentGame))
         {
            currentGame.destroy();
            currentGame = null;
         }
      }
      
      public static function join(param1:String, param2:Boolean = true, param3:uint = 1, param4:Object = null) : void
      {
         if(_isOnline)
         {
            throw new Error("游戏平台中已经有游戏在运行，不能再次加入");
         }
         if(isConnecting)
         {
            Alarm.show("正在连接游戏平台，不能重复发送连接申请");
            return;
         }
         _name = param1;
         paramObj = param4;
         if(param2)
         {
            isConnecting = true;
            SocketConnection.addCmdListener(CommandID.JOIN_GAME,onJoin);
            SocketConnection.send(CommandID.JOIN_GAME,param3);
         }
         else
         {
            _isOnline = false;
            loadGame();
         }
      }
      
      public static function gameOver(param1:uint = 0, param2:uint = 0) : void
      {
         SoundManager.playSound();
         if(_isOnline)
         {
            SocketConnection.addCmdListener(CommandID.GAME_OVER,gameOverHander);
            SocketConnection.send(CommandID.GAME_OVER,param1,param2);
         }
      }
      
      private static function gameOverHander(param1:SocketEvent) : void
      {
         _isOnline = false;
      }
      
      private static function onJoin(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.JOIN_GAME,onJoin);
         _isOnline = true;
         isConnecting = false;
         loadGame();
      }
      
      private static function loadGame() : void
      {
         if(_name == currentName)
         {
            if(!currentGame)
            {
               currentGame = new AppModel(ClientConfig.getGameModule(_name),"正在进入游戏……");
               currentGame.appLoader.addEventListener(MCLoadEvent.CLOSE,onCloseLoading);
               currentGame.setup();
               currentGame.init(paramObj);
            }
            currentGame.show();
            SoundManager.stopSound();
         }
         else
         {
            if(Boolean(currentGame))
            {
               currentGame.appLoader.removeEventListener(MCLoadEvent.CLOSE,onCloseLoading);
               currentGame.destroy();
            }
            currentGame = new AppModel(ClientConfig.getGameModule(_name),"正在进入游戏……");
            currentGame.setup();
            currentGame.init(paramObj);
            currentGame.show();
            SoundManager.stopSound();
         }
         currentName = _name;
      }
      
      private static function onCloseLoading(param1:MCLoadEvent) : void
      {
         if(_isOnline)
         {
            SocketConnection.send(CommandID.GAME_OVER,0,0);
         }
         SoundManager.playSound();
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
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
   }
}

