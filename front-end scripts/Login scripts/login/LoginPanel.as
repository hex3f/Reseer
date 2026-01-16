package login
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.controller.SaveUserInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.SOManager;
   import com.robot.core.net.SocketConnection;
   import event.LoginEvent;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import loginStrategy.EmailLogin;
   import loginStrategy.MiMiIdLogin;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   import others.CommendSvrInfo;
   import others.LoginMSInfo;
   import tip.TipPanel;
   import visualize.AcceptRule;
   import visualize.ParseLoginSocketError;
   import visualize.ServerList;
   
   public class LoginPanel extends Sprite
   {
      
      private static var mySo:SharedObject = SOManager.getCommon_login();
      
      public var idTxt:TextField;
      
      public var passwordTxt:TextField;
      
      private var saveIdBtn:SimpleButton;
      
      private var savapwBtn:SimpleButton;
      
      private var loginBtn:SimpleButton;
      
      public var logMain:loginMain;
      
      public var robotId:String;
      
      public var emailMi:uint;
      
      public var regBtn:SimpleButton;
      
      private var alertTip:TipPanel;
      
      private var sev:ServerList;
      
      private var acceptRule:AcceptRule;
      
      public var lmf:LoginMSInfo;
      
      private var miLogin:MiMiIdLogin;
      
      private var emailLogin:EmailLogin;
      
      private var _miId:String;
      
      private var _password:String;
      
      private var loading:LOADING;
      
      public var emailLog:Boolean = false;
      
      public function LoginPanel()
      {
         var _loc1_:SharedObject = SOManager.getCommonSO("loginInfo");
         var _loc2_:String = null;
         var _loc3_:ByteArray = null;
         super();
         this.logMain = new loginMain();
         this.logMain.x = 0;
         this.logMain.y = 0;
         this.addChild(this.logMain);
         this.idTxt = this.logMain.idTxt;
         this.passwordTxt = this.logMain.pwdTxt;
         this.passwordTxt.displayAsPassword = true;
         this.saveIdBtn = this.logMain.saveMi;
         this.savapwBtn = this.logMain.savePwd;
         this.loginBtn = this.logMain.logBtn;
         this.logMain.savaMiTip.visible = false;
         this.logMain.savaPwdTip.visible = false;
         this.regBtn = this.logMain.regBtn;
         this.passwordTxt.addEventListener(KeyboardEvent.KEY_UP,this.onLoginByEnter);
         this.saveIdBtn.addEventListener(MouseEvent.CLICK,this.savaMiId);
         this.savapwBtn.addEventListener(MouseEvent.CLICK,this.savaPwd);
         this.loginBtn.addEventListener(MouseEvent.CLICK,this.onLogin);
         this._miId = this.idTxt.text;
         this._password = this.passwordTxt.text;
         if(_loc1_.data["id"])
         {
            this.idTxt.text = _loc1_.data["id"];
            this.logMain.savaMiTip.visible = true;
            this.logMain.savaPwdTip.visible = false;
         }
         if(_loc1_.data["pwd"])
         {
            this.passwordTxt.text = _loc1_.data["pwd"];
            this.logMain.savaMiTip.visible = true;
            this.logMain.savaPwdTip.visible = true;
         }
         this.logMain.regBtn.visible = true;
         this.logMain.otherBtn.visible = false;
      }
      
      private function S2B(param1:String) : ByteArray
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         var _loc4_:ByteArray = new ByteArray();
         var _loc5_:uint = uint(param1.length);
         if(_loc5_ == 0 || Boolean(_loc5_ % 2))
         {
            throw new Error("字符长度为" + _loc5_.toString() + "，参数非偶数或为空！");
         }
         var _loc6_:* = 0;
         while(_loc6_ < _loc5_)
         {
            _loc2_ = param1.substr(_loc6_,2);
            _loc3_ = parseInt(_loc2_,16);
            _loc4_.writeByte(_loc3_);
            _loc6_ += 2;
         }
         _loc4_.position = 0;
         return _loc4_;
      }
      
      private function sessionlogin() : void
      {
         this.miLogin = new MiMiIdLogin();
         this.miLogin.addEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         this.miLogin.issessionLogin = true;
         this.miLogin.sendToServer();
      }
      
      private function otherLogin(param1:MouseEvent) : void
      {
         dispatchEvent(new Event("BACK"));
      }
      
      private function savaMiId(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(this.idTxt.text == "")
         {
            return;
         }
         var _loc4_:Array = SaveUserInfo.getUserInfo();
         this.logMain.savaMiTip.visible = !this.logMain.savaMiTip.visible;
         if(!this.logMain.savaMiTip.visible)
         {
            this.logMain.savaPwdTip.visible = false;
            if(_loc4_ == null)
            {
               return;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               if(_loc4_[_loc2_].id == int(this.idTxt.text))
               {
                  _loc4_.splice(_loc2_,1);
               }
               _loc2_++;
            }
            SOManager.flush(mySo);
         }
      }
      
      private function onLoginByEnter(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.loginIn();
         }
      }
      
      private function savaPwd(param1:MouseEvent) : void
      {
         if(this.passwordTxt.text == "")
         {
            return;
         }
         this.logMain.savaPwdTip.visible = !this.logMain.savaPwdTip.visible;
         if(this.logMain.savaPwdTip.visible)
         {
            this.logMain.savaMiTip.visible = true;
            TipPanel.createTipPanel("如果不是你的电脑\n请不要保存密码");
         }
      }
      
      public function clearTxt() : void
      {
         this.idTxt.text = "";
         this.passwordTxt.text = "";
      }
      
      public function get miId() : String
      {
         return this._miId;
      }
      
      public function get password() : String
      {
         return this._password;
      }
      
      public function set miId(param1:String) : void
      {
         this._miId = param1;
      }
      
      public function set password(param1:String) : void
      {
         this._password = param1;
      }
      
      private function loginIn() : void
      {
         EventManager.addEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.onLoginError);
         this._miId = this.idTxt.text;
         this._password = this.passwordTxt.text;
         if(this.idTxt.text == "")
         {
            TipPanel.createTipPanel("你必须输入米米号或注册邮箱才能进入赛尔号哦");
            return;
         }
         var _loc1_:String = this.idTxt.text;
         if(_loc1_.substr(0,1) == "0")
         {
            TipPanel.createTipPanel("你输入米米号不存在请检查后重新输入");
            return;
         }
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:RegExp = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
         _loc2_ = Boolean(_loc4_.test(this.idTxt.text));
         var _loc5_:RegExp = /^[0-9]*[1-9][0-9]*$/;
         _loc3_ = Boolean(_loc5_.test(this.idTxt.text));
         if(_loc2_)
         {
            if(this.passwordTxt.text == "")
            {
               TipPanel.createTipPanel("你必须输入密码才能进入赛尔号哦！");
               return;
            }
            this.emailLogin = new EmailLogin();
            this.emailLogin.addEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
            this.emailLogin.name = this.idTxt.text;
            this.emailLogin.password = this.passwordTxt.text;
            this.emailLogin.sendToServer();
            this.emailLog = true;
            this.loading = new LOADING();
            this.loading.x = 480;
            this.loading.y = 255;
            Login.loginRoot.addChild(this.loading);
         }
         else
         {
            TipPanel.createTipPanel("你要输入正确的注册邮箱.");
         }
         if(this.logMain.savaPwdTip.visible == true)
         {
            Login.bSavaMi = true;
            Login.pwd = this.passwordTxt.text;
         }
         else if(this.logMain.savaMiTip.visible == true && this.logMain.savaPwdTip.visible == false)
         {
            Login.bSavaMi = true;
            Login.pwd = "";
         }
      }
      
      private function onLoginError(param1:Event) : void
      {
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.onLoginError);
         this.loading.stop();
         Login.loginRoot.removeChild(this.loading);
      }
      
      private function onLogin(param1:MouseEvent) : void
      {
         this.loginIn();
      }
      
      private function onLoginOK(param1:LoginEvent) : void
      {
         if(this.emailLog)
         {
            this.emailMi = EmailLogin.eamilUserId;
            this.emailLogin.removeEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         }
         else
         {
            this.miLogin.removeEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         }
         var _loc2_:SharedObject = SOManager.getCommonSO("loginInfo");
         if(this.logMain.savaPwdTip.visible)
         {
            _loc2_.data["id"] = this.idTxt.text;
            _loc2_.data["pwd"] = this.passwordTxt.text;
            SOManager.flush(_loc2_);
         }
         else if(this.logMain.savaMiTip.visible)
         {
            _loc2_.data["id"] = this.idTxt.text;
            _loc2_.data["pwd"] = "";
            SOManager.flush(_loc2_);
         }
         else
         {
            _loc2_.data["id"] = "";
            _loc2_.data["pwd"] = "";
            SOManager.flush(_loc2_);
         }
         this.lmf = param1.loginInfo;
         trace("len:" + LoginMSInfo.session.length);
         var _loc3_:ByteArray = new ByteArray();
         LoginMSInfo.session.position = 0;
         LoginMSInfo.session.readBytes(_loc3_,0,16);
         trace("len:" + _loc3_.length);
         LoginMSInfo.session = _loc3_;
         SocketConnection.mainSocket.userID = EmailLogin.eamilUserId;
         if(this.lmf.roleCreate == 0)
         {
            this.acceptRule = new AcceptRule();
            this.acceptRule.x = 442;
            this.acceptRule.y = 42;
            Login.loginRoot.addChild(this.acceptRule);
            Login.loginRoot.lp.visible = false;
         }
         else
         {
            SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnectPP);
            SocketConnection.mainSocket.addEventListener(Event.CLOSE,this.onConnectClose);
            if(LoginStatus.isHttp)
            {
               trace("LoginPanel.as -- > login by HTTP");
               SocketConnection.mainSocket.connect(LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
            }
            else
            {
               trace("LoginPanel.as -- > login by NROMAL");
               SocketConnection.mainSocket.connect(ClientConfig.SUB_SERVER_IP,ClientConfig.SUB_SERVER_PORT);
            }
         }
      }
      
      public function createroleFun() : void
      {
         this.acceptRule = new AcceptRule();
         this.acceptRule.x = 442;
         this.acceptRule.y = 42;
         Login.loginRoot.addChild(this.acceptRule);
         Login.loginRoot.lp.visible = false;
      }
      
      private function onConnectPP(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnectPP);
         SocketConnection.addCmdListener(CommandID.COMMEND_ONLINE,this.getCommendList);
         EventManager.addEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.getCommendListError);
         SocketConnection.send(CommandID.COMMEND_ONLINE,LoginMSInfo.session,MainManager.CHANNEL);
      }
      
      private function getCommendListError(param1:Event) : void
      {
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.getCommendListError);
         SocketConnection.removeCmdListener(CommandID.COMMEND_ONLINE,this.getCommendList);
      }
      
      private function onConnectClose(param1:Event) : void
      {
         var e:Event = param1;
         trace("socket关闭，断开连接");
         TipPanel.createTipPanel("此次连接已经断开，请重新登陆",function():void
         {
         });
      }
      
      private function getCommendList(param1:SocketEvent) : void
      {
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.getCommendListError);
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.onLoginError);
         this.visible = false;
         if(Boolean(this.loading))
         {
            this.loading.stop();
         }
         DisplayUtil.removeForParent(this.loading);
         SocketConnection.removeCmdListener(CommandID.COMMEND_ONLINE,this.getCommendList);
         var _loc2_:CommendSvrInfo = param1.data as CommendSvrInfo;
         Login.isVip = Boolean(_loc2_.IsVIP);
         this.sev = new ServerList(_loc2_);
         this.sev.x = 49;
         this.sev.y = 54;
         Login.loginRoot.addChild(this.sev);
      }
      
      public function destroy() : void
      {
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.getCommendListError);
         SocketConnection.mainSocket.removeEventListener(Event.CLOSE,this.onConnectClose);
         EventManager.removeEventListener(ParseLoginSocketError.LOGIN_SEER_ERRORS,this.onLoginError);
      }
      
      public function externalLogin(param1:uint, param2:String) : void
      {
         this.miLogin = new MiMiIdLogin();
         this.miLogin.addEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         this.miLogin.name = param1.toString();
         this.miLogin.password = param2;
         this.miLogin.isBeMD5 = true;
         this.miLogin.sendToServer();
      }
   }
}

