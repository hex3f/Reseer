package register
{
   import com.robot.core.CommandID;
   import com.robot.core.ErrorReport;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.net.SocketConnection;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.tmf.HeadInfo;
   import tip.TipPanel;
   import visualize.SeerVerify;
   
   public class RegisterManage extends Sprite
   {
      
      public static var curEmail:String;
      
      public static var bDirectReg:Boolean = false;
      
      public var regPanel:RegisterPanel;
      
      private var registerOver:RegisterOver;
      
      public var robotId:String;
      
      private var loader:URLLoader;
      
      public var bRegister:Boolean = false;
      
      private var regAlertTip:TipPanel;
      
      private var _headerInfo:HeadInfo;
      
      private var emailCodeRes:String;
      
      private var _emailAddress:String;
      
      private var _emailCode:String;
      
      private var _pwd:String;
      
      public function RegisterManage()
      {
         super();
         this.regPanel = new RegisterPanel();
         this.regPanel.x = 0;
         this.regPanel.y = 0;
         addChild(this.regPanel);
         this.regPanel.confirmBtn.addEventListener(MouseEvent.CLICK,this.onConfirm);
         this.regPanel.cancelBtn.addEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      public function clearRegInfo() : void
      {
         this.regPanel.clearTxt();
      }
      
      private function onConfirm(param1:MouseEvent) : void
      {
         var _loc2_:String = "";
         if(this.regPanel.passwordTxt.text == "最少六个字母或符号" || this.regPanel.passwordTxt.text == "")
         {
            _loc2_ = "请输入密码";
            TipPanel.createTipPanel(_loc2_);
            return;
         }
         if(!this.checkPsw())
         {
            return;
         }
         if(this.regPanel.agPasswrodTxt.text == "和上面的密码一样" || this.regPanel.agPasswrodTxt.text == "")
         {
            _loc2_ = "确认密码没有输入";
            TipPanel.createTipPanel(_loc2_);
            return;
         }
         if(this.regPanel.emailTxt.text == "")
         {
            _loc2_ = "请输入Email";
            TipPanel.createTipPanel(_loc2_);
            return;
         }
         if(!this.regPanel.bRightEmail)
         {
            this.regPanel.emailTip.text = "Email地址格式不正确";
         }
         if(this.regPanel.bRightEmail && this.regPanel.bRightPw)
         {
            curEmail = this.regPanel.emailTxt.text;
            EventManager.addEventListener(SeerVerify.SEER_VERIFY_OK,this.onVerifyOk);
            return;
         }
      }
      
      private function checkPsw() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc7_:Boolean = true;
         var _loc8_:String = this.regPanel.passwordTxt.text;
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_.length)
         {
            if(_loc9_ > 0)
            {
               _loc2_ = int(_loc8_.charCodeAt(_loc9_ - 1));
               _loc3_ = int(_loc8_.charCodeAt(_loc9_));
               if(_loc2_ == _loc3_)
               {
                  _loc4_++;
               }
               if(_loc2_ + 1 == _loc3_)
               {
                  _loc5_++;
               }
               if(_loc2_ - 1 == _loc3_)
               {
                  _loc6_++;
               }
            }
            _loc9_++;
         }
         if(!_loc7_)
         {
            TipPanel.createTipPanel(_loc1_);
         }
         return _loc7_;
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.visible = false;
         Login.loginRoot.lp.visible = true;
         if(this.regAlertTip != null)
         {
            this.regAlertTip.visible = false;
         }
      }
      
      private function onVerifyOk(param1:Event) : void
      {
         EventManager.removeEventListener(SeerVerify.SEER_VERIFY_OK,this.onVerifyOk);
         SocketConnection.addCmdListener(CommandID.REGISTER,this.onRegisterInfo);
         this.sendRegisterInfo();
      }
      
      public function getMiId() : String
      {
         return this._headerInfo.userID.toString();
      }
      
      private function onRegisterInfo(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.REGISTER,this.onRegisterInfo);
         this._headerInfo = param1.headInfo;
         this.bRegister = true;
         trace("Header result: " + this._headerInfo.result);
         if(this._headerInfo.result == 0)
         {
            bDirectReg = true;
            this.regPanel.visible = false;
            this.registerOver = new RegisterOver(this);
            this.registerOver.x = 0;
            this.registerOver.y = 0;
            this.registerOver.visible = true;
            addChild(this.registerOver);
            trace("RegisterOver panel added to display list and set visible");
            trace("RegisterOver visibility: " + this.registerOver.visible);
            TipPanel.createTipPanel("注册成功，米米号为：" + this.getMiId() + "，请牢记米米号，并返回登录界面使用邮箱登录!");
         }
         else
         {
            trace("Header result is not 0, panel not created");
         }
      }
      
      public function sendToServer(param1:String, param2:String, param3:String) : void
      {
         this._emailAddress = param1;
         this._emailCode = param2;
         this._pwd = param3;
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnect);
         this.loader = new URLLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.load(new URLRequest(ClientConfig.httpURL + "?" + Math.random()));
      }
      
      public function sendEmailToServer(param1:String) : void
      {
         this._emailAddress = param1;
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnectSendEmail);
         this.loader = new URLLoader();
         this.loader.addEventListener(Event.COMPLETE,this.onLoadHttp);
         this.loader.load(new URLRequest(ClientConfig.httpURL + "?" + Math.random()));
      }
      
      private function onConnectSendEmail(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnectSendEmail);
         SocketConnection.addCmdListener(3,this.onSendEmail);
         this.sendEmail();
      }
      
      private function onSendEmail(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(3,this.onSendEmail);
         var _loc2_:* = param1.data as ByteArray;
         this.emailCodeRes = _loc2_.readUTFBytes(32);
         TipPanel.createTipPanel("发送验证码成功，请查看邮箱(有可能被放入邮件垃圾箱)!");
      }
      
      private function sendEmail() : void
      {
         var _loc1_:ByteArray = new ByteArray();
         var _loc2_:String = this._emailAddress;
         _loc1_.writeUTFBytes(_loc2_);
         _loc1_.length = 64;
         SocketConnection.send(3,_loc1_);
      }
      
      private function onLoadHttp(param1:Event) : void
      {
         this.loader.removeEventListener(Event.COMPLETE,this.onLoadHttp);
         var _loc2_:String = param1.currentTarget.data;
         if(LoginStatus.isHttp)
         {
            LoginStatus.HTTP_IP = _loc2_.split(":")[0];
            LoginStatus.HTTP_PORT = uint(_loc2_.split(":")[1]);
            trace("connect by http -------------> ",LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
            SocketConnection.mainSocket.connect(LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
         }
      }
      
      private function onConnect(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSecurityError);
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnect);
         SocketConnection.addCmdListener(CommandID.REGISTER,this.onRegisterInfo);
         this.sendRegisterInfo();
      }
      
      private function sendRegisterInfo() : void
      {
         var _loc1_:ByteArray = new ByteArray();
         var _loc2_:String = this._pwd;
         _loc1_.writeUTFBytes(_loc2_);
         _loc1_.length = 32;
         var _loc3_:ByteArray = new ByteArray();
         var _loc4_:String = this._emailAddress;
         _loc3_.writeUTFBytes(_loc4_);
         _loc3_.length = 64;
         var _loc5_:String = "m";
         var _loc6_:Number = 30;
         var _loc7_:Number = 1999;
         var _loc8_:ByteArray = new ByteArray();
         _loc8_.length = 0;
         var _loc9_:String = "13645213654";
         var _loc10_:ByteArray = new ByteArray();
         _loc10_.writeUTFBytes(_loc9_);
         _loc10_.length = 16;
         var _loc11_:String = "sh";
         var _loc12_:String = "sh";
         var _loc13_:String = "fdsafsdaf";
         var _loc14_:ByteArray = new ByteArray();
         _loc14_.writeUTFBytes(_loc13_);
         _loc14_.length = 64;
         var _loc15_:String = "fdsafsdafsafdsafas";
         var _loc16_:ByteArray = new ByteArray();
         _loc16_.length = 128;
         var _loc17_:ByteArray = new ByteArray();
         var _loc18_:String = this._emailCode;
         _loc17_.writeUTFBytes(_loc18_);
         _loc17_.length = 32;
         var _loc19_:ByteArray = new ByteArray();
         var _loc20_:String = this.emailCodeRes;
         _loc19_.writeUTFBytes(_loc20_);
         _loc19_.length = 32;
         SocketConnection.send(CommandID.REGISTER,_loc1_,_loc3_,_loc17_,_loc19_);
      }
      
      private function onSecurityError(param1:SecurityErrorEvent) : void
      {
         TipPanel.createTipPanel("此次连接错误，请稍后重试");
         ErrorReport.sendError(ErrorReport.REGISTE_ERROR);
      }
   }
}

