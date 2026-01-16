package com.robot.app
{
   import com.robot.app.cmd.OfflineExpCmdListener;
   import com.robot.app.cmd.SysMsgCmdListener;
   import com.robot.core.CommandID;
   import com.robot.core.ErrorReport;
   import com.robot.core.cmd.ChatCmdListener;
   import com.robot.core.cmd.InformCmdListener;
   import com.robot.core.cmd.team.TeamInformCmdListener;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.controller.SaveUserInfo;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.AssetsManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.mail.MailManager;
   import com.robot.core.manager.map.config.MapConfig;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.utils.ByteArray;
   import org.taomee.component.manager.MComponentManager;
   import org.taomee.events.SocketErrorEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.TaomeeManager;
   import org.taomee.manager.TickManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.net.SocketDispatcher;
   
   public class MainEntry
   {
      
      public static var Assets_PATH:String = "dll/Assets.swf";
      
      public function MainEntry()
      {
         super();
      }
      
      public function setup(param1:Sprite, param2:String, param3:uint, param4:uint, param5:ByteArray, param6:ByteArray, param7:Boolean, param8:String) : void
      {
         var AssetsLoader:MCLoader;
         var sprite:Sprite = param1;
         var ip:String = param2;
         var port:uint = param3;
         var userID:uint = param4;
         var session:ByteArray = param5;
         var relData:ByteArray = param6;
         var isSave:Boolean = param7;
         var pass:String = param8;
         MComponentManager.setup(sprite,14,"Tahoma");
         TaomeeManager.setup(sprite,sprite.stage);
         TaomeeManager.stageWidth = 960;
         TaomeeManager.stageHeight = 560;
         MainManager.actorID = userID;
         ItemXMLInfo.parseInfo();
         LevelManager.setup(sprite);
         ClassRegister.setup();
         TickManager.setup();
         new OfflineExpCmdListener().start();
         new ChatCmdListener().start();
         new InformCmdListener().start();
         SysMsgCmdListener.getInstance().start();
         new TeamInformCmdListener().start();
         MailManager.setup();
         AssetsLoader = new MCLoader(Assets_PATH,sprite,1,"正在加载核心资源");
         AssetsLoader.setIsShowClose(false);
         AssetsLoader.addEventListener(MCLoadEvent.SUCCESS,function(param1:MCLoadEvent):void
         {
            AssetsManager.setup(param1.getLoader());
            SocketConnection.mainSocket.userID = userID;
            SocketConnection.mainSocket.session = session;
            SocketConnection.mainSocket.ip = ip;
            SocketConnection.mainSocket.port = port;
            SocketConnection.mainSocket.addEventListener(Event.CONNECT,onConnect);
            SocketConnection.mainSocket.connect(ip,port);
            SaveUserInfo.isSave = isSave;
            SaveUserInfo.pass = pass;
         });
         AssetsLoader.doLoad();
      }
      
      private function onConnect(param1:Event) : void
      {
         SocketConnection.mainSocket.addEventListener(Event.CLOSE,this.socketClose);
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.addCmdListener(CommandID.LOGIN_IN,this.onLogin);
         SocketConnection.send(CommandID.LOGIN_IN,SocketConnection.mainSocket.session);
      }
      
      private function socketClose(param1:Event) : void
      {
         var event:Event = param1;
         var sprite:Sprite = null;
         ErrorReport.sendError(ErrorReport.SOCKET_CLOSE_ERROR);
         try
         {
            sprite = Alarm.show("此次连接已经断开，请重新登陆",function():void
            {
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("function() { location.reload(); }");
               }
            },false,true);
            LevelManager.iconLevel.addChild(sprite);
         }
         catch(e:Error)
         {
         }
      }
      
      private function onLogin(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.LOGIN_IN,this.onLogin);
         SocketDispatcher.getInstance().addEventListener(SocketErrorEvent.ERROR,this.onError);
         EventManager.addEventListener(RobotEvent.CREATED_ACTOR,this.onCreatedActor);
         MapConfig.setup();
         MainManager.setup(param1.data);
      }
      
      private function onCreatedActor(param1:RobotEvent) : void
      {
         EventManager.removeEventListener(RobotEvent.CREATED_ACTOR,this.onCreatedActor);
         ToolTipManager.setup(UIManager.getSprite("Tooltip_Background"));
         SaveUserInfo.saveSo();
      }
      
      private function onError(param1:SocketErrorEvent) : void
      {
         if(!param1.headInfo)
         {
            ParseSocketError.parse(1,0);
         }
         else
         {
            ParseSocketError.parse(param1.headInfo.result,param1.headInfo.cmdID);
         }
      }
   }
}

