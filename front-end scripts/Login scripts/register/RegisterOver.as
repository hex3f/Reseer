package register
{
   import event.LoginEvent;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import loginStrategy.MiMiIdLogin;
   import tip.TipPanel;
   import visualize.AcceptRule;
   
   public class RegisterOver extends Sprite
   {
      
      private var regManage:RegisterManage;
      
      private var goLoginBtn:SimpleButton;
      
      private var loginOkMC:regOkMC;
      
      private var acceptRule:AcceptRule;
      
      private var miLogin:MiMiIdLogin;
      
      public function RegisterOver(param1:RegisterManage)
      {
         super();
         this.regManage = param1;
         this.loginOkMC = new regOkMC();
         this.loginOkMC.x = 0;
         this.loginOkMC.y = 0;
         addChild(this.loginOkMC);
         trace("loginOkMC added to display list");
         trace("loginOkMC visibility: " + this.loginOkMC.visible);
         trace("loginOkMC coordinates: (" + this.loginOkMC.x + ", " + this.loginOkMC.y + ")");
         trace("loginOkMC dimensions: " + this.loginOkMC.width + "x" + this.loginOkMC.height);
         this.loginOkMC.miIdTxt.text = param1.getMiId();
         this.loginOkMC.miPwd.text = param1.regPanel.getPwd();
         this.loginOkMC.emailTxt.text = param1.regPanel.getEmail();
         this.goLoginBtn = this.loginOkMC.regOkBtn;
         this.goLoginBtn.addEventListener(MouseEvent.CLICK,this.goToLogin);
         trace("RegisterOver initialization complete");
         trace("RegisterOver coordinates: (" + this.x + ", " + this.y + ")");
         trace("RegisterOver dimensions: " + this.width + "x" + this.height);
      }
      
      private function goToLogin(param1:MouseEvent) : void
      {
         if(this.regManage.bRegister)
         {
            this.login();
            this.acceptRule = new AcceptRule();
            this.acceptRule.x = 442;
            this.acceptRule.y = 42;
            Login.loginRoot.addChild(this.acceptRule);
            Login.loginRoot.lp.miId = this.regManage.getMiId();
            Login.loginRoot.lp.password = this.regManage.regPanel.getPwd();
         }
         this.regManage.visible = false;
      }
      
      private function login() : void
      {
         this.miLogin = new MiMiIdLogin();
         this.miLogin.addEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         this.miLogin.addEventListener(LoginEvent.ON_LOGIN_ERROR,this.onLoginError);
         this.miLogin.name = this.regManage.getMiId();
         this.miLogin.password = this.regManage.regPanel.getPwd();
         this.miLogin.sendToServer();
      }
      
      private function onLoginOK(param1:LoginEvent) : void
      {
         this.miLogin.removeEventListener(LoginEvent.ON_LOGIN_OK,this.onLoginOK);
         this.miLogin.removeEventListener(LoginEvent.ON_LOGIN_ERROR,this.onLoginError);
         Login.loginRoot.lp.lmf = param1.loginInfo;
         Login.bSavaMi = true;
         Login.pwd = "";
      }
      
      private function onLoginError(param1:LoginEvent) : void
      {
         this.miLogin.removeEventListener(LoginEvent.ON_LOGIN_ERROR,this.onLoginError);
         var _loc2_:String = "";
         switch(param1.errorCode)
         {
            case "5001":
               _loc2_ = "系统错误";
               break;
            case "5003":
               _loc2_ = "密码错误\n注意区分英文大小写";
               break;
            case "5005":
               _loc2_ = "你输入米米号不存在请检查后重新输入";
               break;
            case "5008":
               _loc2_ = "此帐户因多次输入密码错误暂时关闭请稍候再试";
         }
         if(_loc2_ != "")
         {
            TipPanel.createTipPanel(_loc2_);
         }
      }
   }
}

