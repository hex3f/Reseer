package loginStrategy
{
   import com.adobe.crypto.MD5;
   import com.robot.core.CommandID;
   import com.robot.core.ErrorReport;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.net.SocketConnection;
   import event.LoginEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
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
   
   public class MiMiIdLogin extends EventDispatcher implements ILoginType
   {
      
      private var _name:String;
      
      private var _password:String;
      
      private var lms:LoginMSInfo;
      
      private var _isBeMD5:Boolean = false;
      
      private var loader:URLLoader;
      
      private var isOutOfTime:Boolean = false;
      
      private var timer:Timer;
      
      private var _issessionLogin:Boolean;
      
      public function MiMiIdLogin()
      {
         super();
         this.timer = new Timer(5000,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      public function get issessionLogin() : Boolean
      {
         return this._issessionLogin;
      }
      
      public function set issessionLogin(param1:Boolean) : void
      {
         this._issessionLogin = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get password() : String
      {
         return this._password;
      }
      
      public function set isBeMD5(param1:Boolean) : void
      {
         this._isBeMD5 = param1;
      }
      
      public function set password(param1:String) : void
      {
         this._password = param1;
      }
      
      public function sendToServer() : void
      {
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.mainSocket.addEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         SocketConnection.mainSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         this.loader = new URLLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onLoadError);
         this.loader.load(new URLRequest(ClientConfig.httpURL + "?" + Math.random()));
         LoginStatus.isHttp = true;
         this.timer.start();
         trace("正在请求HTTP地址");
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         trace("connect http out of time..............");
         this.isOutOfTime = true;
         LoginStatus.isHttp = false;
         SocketConnection.mainSocket.connect(ClientConfig.ID_IP,ClientConfig.ID_PORT);
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
            if(this.issessionLogin)
            {
               SocketConnection.mainSocket.removeEventListener(IOErrorEvent.IO_ERROR,this.onIO);
               SocketConnection.mainSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
               SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnect);
               this.lms = new LoginMSInfo(null);
               this.lms.roleCreate = 1;
               dispatchEvent(new LoginEvent(LoginEvent.ON_LOGIN_OK,this.lms,null));
            }
            else
            {
               SocketConnection.mainSocket.connect(LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
            }
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
         trace(ClientConfig.ID_IP,ClientConfig.ID_PORT);
         SocketConnection.mainSocket.connect(ClientConfig.ID_IP,ClientConfig.ID_PORT);
      }
      
      private function onIO(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         TipPanel.createTipPanel("服务器没有开启");
      }
      
      private function onConnect(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(IOErrorEvent.IO_ERROR,this.onIO);
         SocketConnection.mainSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.addCmdListener(CommandID.MAIN_LOGIN_IN,this.onLoginsc);
         var _loc2_:uint = uint(int(this._name));
         SocketConnection.mainSocket.userID = _loc2_;
         var _loc3_:ByteArray = new ByteArray();
         if(this._isBeMD5)
         {
            _loc3_.writeUTFBytes(this._password);
         }
         else
         {
            _loc3_.writeUTFBytes(MD5.hash(this._password));
         }
         _loc3_.length = 32;
         var _loc4_:Number = 30;
         var _loc5_:Number = 2;
         SocketConnection.send(CommandID.MAIN_LOGIN_IN,_loc3_,_loc4_,_loc5_,0);
         SocketDispatcher.getInstance().addEventListener(SocketErrorEvent.ERROR,this.onLoginError);
      }
      
      private function onLoginError(param1:SocketErrorEvent) : void
      {
         SocketDispatcher.getInstance().removeEventListener(SocketErrorEvent.ERROR,this.onLoginError);
         EventManager.dispatchEvent(new Event(ParseLoginSocketError.LOGIN_SEER_ERRORS));
      }
      
      private function onLoginsc(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.MAIN_LOGIN_IN,this.onLoginsc);
         if(param1.headInfo.result == 0)
         {
            this.lms = param1.data as LoginMSInfo;
            dispatchEvent(new LoginEvent(LoginEvent.ON_LOGIN_OK,this.lms,null));
         }
      }
      
      public function getServerList() : Array
      {
         return new Array();
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         TipPanel.createTipPanel("此次连接错误，请稍后重试");
         ErrorReport.sendError(ErrorReport.MIMI_LOGIN_ERROR);
      }
   }
}

