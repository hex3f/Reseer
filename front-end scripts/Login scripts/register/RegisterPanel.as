package register
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import tip.TipPanel;
   
   public class RegisterPanel extends Sprite
   {
      
      public var passwordTxt:TextField;
      
      private var pwTip:TextField;
      
      public var agPasswrodTxt:TextField;
      
      public var confirmBtn:SimpleButton;
      
      private var agPwTip:TextField;
      
      public var emailTxt:TextField;
      
      public var emailTip:TextField;
      
      public var bRightPw:Boolean = false;
      
      public var bRightEmail:Boolean = false;
      
      private var regM:regMiPanel;
      
      private var pwdRight:right;
      
      private var agPRight:right;
      
      public var emailRight:right;
      
      public var cancelBtn:SimpleButton;
      
      private var formatTxt:TextFormat;
      
      public var emailCodeTxt:TextField;
      
      public var emailButton:SimpleButton;
      
      private var registerManage:RegisterManage;
      
      public function RegisterPanel()
      {
         super();
         this.formatTxt = new TextFormat();
         this.formatTxt.color = 0;
         this.regM = new regMiPanel();
         this.regM.x = 0;
         this.regM.y = 0;
         addChild(this.regM);
         this.passwordTxt = this.regM.pwdTxt;
         this.passwordTxt.type = TextFieldType.INPUT;
         this.passwordTxt.addEventListener(FocusEvent.FOCUS_IN,this.clearPwTxt);
         this.passwordTxt.addEventListener(Event.CHANGE,this.regPw);
         this.pwTip = this.regM.regPwdTxt;
         this.pwTip.type = TextFieldType.DYNAMIC;
         this.pwTip.width = 300;
         this.agPasswrodTxt = this.regM.agPwdTxt;
         this.agPasswrodTxt.type = TextFieldType.INPUT;
         this.agPasswrodTxt.addEventListener(FocusEvent.FOCUS_IN,this.clearAPwTxt);
         this.agPasswrodTxt.addEventListener(Event.CHANGE,this.regAgPw);
         this.agPwTip = this.regM.agPwdTip;
         this.agPwTip.type = TextFieldType.DYNAMIC;
         this.emailTxt = this.regM.emailTxt;
         this.emailTxt.type = TextFieldType.INPUT;
         this.emailTxt.addEventListener(Event.CHANGE,this.regEmail);
         this.emailTxt.addEventListener(FocusEvent.FOCUS_IN,this.clearEmailTxt);
         this.emailTip = this.regM.emailTip;
         this.emailTip.type = TextFieldType.DYNAMIC;
         this.confirmBtn = this.regM.getMiBtn;
         this.cancelBtn = this.regM.exitBtn;
         this.regM.setChildIndex(this.confirmBtn,this.regM.numChildren - 1);
         this.confirmBtn.addEventListener(MouseEvent.CLICK,this.otherLogin);
         this.emailCodeTxt = this.regM.emailCodeTxt;
         this.emailCodeTxt.type = TextFieldType.INPUT;
         this.emailButton = this.regM.emailButton;
         this.emailButton.addEventListener(MouseEvent.CLICK,this.sendEmail);
         this.initRight();
      }
      
      public static function getCode() : String
      {
         return "";
      }
      
      private function otherLogin(param1:MouseEvent) : void
      {
         if(this.registerManage == null)
         {
            this.registerManage = new RegisterManage();
         }
         var _loc2_:String = this.emailTxt.text;
         var _loc3_:String = this.emailCodeTxt.text;
         var _loc4_:String = this.passwordTxt.text;
         this.registerManage.sendToServer(_loc2_,_loc3_,_loc4_);
      }
      
      private function sendEmail(param1:MouseEvent) : void
      {
         var emailAddress:String;
         if(this.registerManage == null)
         {
            this.registerManage = new RegisterManage();
         }
         setTimeout(function():void
         {
            TipPanel.createTipPanel("正在发送验证码到邮箱,切勿刷新游戏！");
         },30);
         emailAddress = this.emailTxt.text;
         this.registerManage.sendEmailToServer(emailAddress);
      }
      
      private function clearPwTxt(param1:FocusEvent) : void
      {
         if(this.passwordTxt.text == "最少六个字母或符号")
         {
            this.passwordTxt.text = "";
            this.passwordTxt.removeEventListener(FocusEvent.FOCUS_IN,this.clearPwTxt);
         }
      }
      
      private function clearICTxt(param1:FocusEvent) : void
      {
      }
      
      private function clearEmailTxt(param1:FocusEvent) : void
      {
         if(this.emailTxt.text == "@.com")
         {
            this.emailTxt.text = "";
            this.emailTxt.removeEventListener(FocusEvent.FOCUS_IN,this.clearEmailTxt);
         }
      }
      
      private function clearAPwTxt(param1:FocusEvent) : void
      {
         if(this.agPasswrodTxt.text == "和上面的密码一样")
         {
            this.agPasswrodTxt.text = "";
            this.agPasswrodTxt.removeEventListener(FocusEvent.FOCUS_IN,this.clearAPwTxt);
         }
      }
      
      private function initRight() : void
      {
         this.pwdRight = new right();
         this.pwdRight.x = 340;
         this.pwdRight.y = 126;
         this.pwdRight.width = 25;
         this.pwdRight.height = 15;
         this.regM.addChild(this.pwdRight);
         this.pwdRight.visible = false;
         this.agPRight = new right();
         this.agPRight.x = 340;
         this.agPRight.y = 160;
         this.agPRight.width = 25;
         this.agPRight.height = 15;
         this.regM.addChild(this.agPRight);
         this.agPRight.visible = false;
         this.emailRight = new right();
         this.emailRight.x = 340;
         this.emailRight.y = 190;
         this.emailRight.width = 25;
         this.emailRight.height = 15;
         this.emailRight.visible = false;
         this.regM.addChild(this.emailRight);
      }
      
      public function getEmail() : String
      {
         return this.emailTxt.text;
      }
      
      public function getEmailCode() : String
      {
         return this.emailCodeTxt.text;
      }
      
      public function getPwd() : String
      {
         return this.agPasswrodTxt.text;
      }
      
      private function regEmail(param1:Event) : void
      {
         this.emailTxt.setTextFormat(this.formatTxt);
         var _loc2_:Boolean = false;
         var _loc3_:RegExp = /\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/;
         _loc2_ = Boolean(_loc3_.test(this.emailTxt.text));
         if(_loc2_)
         {
            this.emailTip.text = "";
            this.emailRight.visible = true;
            this.bRightEmail = true;
         }
         else
         {
            this.emailTip.text = "email格式不正确";
            this.emailRight.visible = false;
            this.bRightEmail = false;
         }
      }
      
      private function regAgPw(param1:Event) : void
      {
         this.agPasswrodTxt.displayAsPassword = true;
         this.agPasswrodTxt.setTextFormat(this.formatTxt);
         var _loc2_:String = this.agPasswrodTxt.text;
         this.agPasswrodTxt.restrict = "A-Za-z0-9 ";
         var _loc3_:RegExp = /[A-Za-z0-9 ]{6,32}/;
         var _loc4_:Boolean = Boolean(_loc3_.test(_loc2_));
         if(_loc2_ == this.passwordTxt.text && _loc4_ && _loc2_ != "")
         {
            this.agPwTip.text = "";
            this.agPRight.visible = true;
            this.bRightPw = true;
            if(this.passwordTxt.text.length > 32)
            {
               this.agPRight.visible = false;
               this.bRightPw = false;
            }
         }
         else
         {
            this.bRightPw = false;
            this.agPRight.visible = false;
            this.agPwTip.text = "两次密码输入不一致";
         }
      }
      
      public function clearTxt() : void
      {
         this.passwordTxt.text = "最少六个字母或符号";
         this.passwordTxt.textColor = 0;
         this.agPasswrodTxt.text = "和上面的密码一样";
         this.agPasswrodTxt.textColor = 0;
         this.pwdRight.visible = false;
         this.agPRight.visible = false;
         this.emailRight.visible = false;
         this.emailTxt.text = "@.com";
         this.emailTxt.textColor = 0;
         this.pwTip.text = "";
         this.bRightEmail = false;
         this.agPwTip.text = "";
         this.emailTip.text = "";
         this.bRightPw = false;
      }
      
      private function regPw(param1:Event) : void
      {
         this.passwordTxt.displayAsPassword = true;
         this.passwordTxt.setTextFormat(this.formatTxt);
         this.passwordTxt.restrict = "A-Za-z0-9 ";
         var _loc2_:RegExp = /[A-Za-z0-9 ]{6,32}/;
         var _loc3_:Boolean = Boolean(_loc2_.test(this.passwordTxt.text));
         if(this.passwordTxt.text.length > 32)
         {
            this.pwTip.text = "密码太长了";
            this.pwdRight.visible = false;
            this.agPwTip.text = "";
            this.agPRight.visible = false;
            this.bRightPw = false;
            this.agPasswrodTxt.text = "";
            this.bRightPw = false;
            return;
         }
         if(_loc3_)
         {
            this.pwTip.text = "";
            if(this.agPasswrodTxt.text != this.passwordTxt.text && this.agPasswrodTxt.text != "")
            {
               this.bRightPw = false;
               this.agPwTip.text = "两次密码输入不一致";
               this.agPRight.visible = false;
            }
            else if(this.agPasswrodTxt.text == this.passwordTxt.text)
            {
               this.agPwTip.text = "";
               this.agPRight.visible = true;
               this.bRightPw = true;
            }
            this.pwdRight.visible = true;
         }
         else if(this.passwordTxt.text == "")
         {
            this.pwTip.text = "最少6个字母或符号";
            this.pwdRight.visible = false;
            this.agPwTip.text = "";
            this.agPRight.visible = false;
            this.bRightPw = false;
            this.agPasswrodTxt.text = "";
         }
         else
         {
            this.pwdRight.visible = false;
            this.pwTip.text = "密码太短了";
         }
      }
   }
}

