package loginStrategy
{
   import com.adobe.crypto.MD5;
   import com.robot.core.CommandID;
   import com.robot.core.ErrorReport;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.net.SocketConnection;
   import event.LoginEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import org.taomee.events.SocketErrorEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.net.SocketDispatcher;
   import others.LoginMSInfo;
   import tip.TipPanel;
   import visualize.ParseLoginSocketError;
   
   public class EmailLogin extends MiMiIdLogin
   {
      
      public static var eamilUserId:uint;
      
      private var timer:Timer;
      
      private var lms:LoginMSInfo;
      
      private var isOutOfTime:Boolean = false;
      
      private var loader:URLLoader;
      
      public function EmailLogin()
      {
         super();
         this.timer = new Timer(5000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         trace("connect http out of time..............");
         this.isOutOfTime = true;
         LoginStatus.isHttp = false;
         SocketConnection.mainSocket.connect(ClientConfig.EMAIL_IP,ClientConfig.EMAIL_PORT);
      }
      
      override public function sendToServer() : void
      {
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.mainSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         SocketConnection.mainSocket.addEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         this.loader = new URLLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.loader.load(new URLRequest(ClientConfig.httpURL + "?" + Math.random()));
         LoginStatus.isHttp = true;
         this.timer.start();
      }
      
      private function onLoadHttp(param1:Event) : void
      {
         this.loader.removeEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         if(this.isOutOfTime)
         {
            return;
         }
         var _loc2_:String = param1.currentTarget.data;
         if(LoginStatus.isHttp)
         {
            this.timer.stop();
            LoginStatus.HTTP_IP = _loc2_.split(":")[0];
            LoginStatus.HTTP_PORT = uint(_loc2_.split(":")[1]);
            trace("connect by http -------------> ",LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
            SocketConnection.mainSocket.connect(LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
         }
      }
      
      private function onLoadError(param1:*) : void
      {
         this.loader.removeEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         if(this.isOutOfTime)
         {
            return;
         }
         LoginStatus.isHttp = false;
         trace("connect by http ERROR,Login By NORMAL-----------");
         this.timer.stop();
         SocketConnection.mainSocket.connect(ClientConfig.EMAIL_IP,ClientConfig.EMAIL_PORT);
      }
      
      private function onIO(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         TipPanel.createTipPanel("服务器没有开启");
      }
      
      private function onConnect(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.mainSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         SocketConnection.addCmdListener(CommandID.MAIN_LOGIN_IN,this.onLoginsc);
         SocketConnection.mainSocket.userID = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(this.name);
         _loc2_.length = 64;
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(MD5.hash(this.password));
         _loc3_.length = 32;
         var _loc4_:Number = 30;
         var _loc5_:Number = 2;
         SocketDispatcher.getInstance().addEventListener(SocketErrorEvent.ERROR,this.onLoginError);
         SocketConnection.send(CommandID.MAIN_LOGIN_IN,_loc2_,_loc3_,_loc4_,_loc5_,0);
      }
      
      private function onLoginError(param1:SocketErrorEvent) : void
      {
         SocketDispatcher.getInstance().removeEventListener(SocketErrorEvent.ERROR,this.onLoginError);
         EventManager.dispatchEvent(new Event(ParseLoginSocketError.LOGIN_SEER_ERRORS));
      }
      
      private function onLoginsc(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.MAIN_LOGIN_IN,this.onLoginsc);
         SocketDispatcher.getInstance().removeEventListener(SocketErrorEvent.ERROR,this.onLoginError);
         if(param1.headInfo.result == 0)
         {
            eamilUserId = param1.headInfo.userID;
            SocketConnection.mainSocket.userID = eamilUserId;
            this.lms = param1.data as LoginMSInfo;
            dispatchEvent(new LoginEvent(LoginEvent.ON_LOGIN_OK,this.lms,null));
         }
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         TipPanel.createTipPanel("此次连接错误，请稍后重试");
         ErrorReport.sendError(ErrorReport.EMAIL_LOGIN_ERROR);
      }
   }
}

