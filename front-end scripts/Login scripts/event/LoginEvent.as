package event
{
   import flash.events.Event;
   import others.LoginMSInfo;
   
   public class LoginEvent extends Event
   {
      
      public static var ON_LOGIN_OK:String = "on_login_ok";
      
      public static var ON_LOGIN_ERROR:String = "on_login_error";
      
      private var _loginInfo:LoginMSInfo;
      
      private var _errorCode:String;
      
      public function LoginEvent(param1:String, param2:LoginMSInfo, param3:String)
      {
         super(param1,false,false);
         this._loginInfo = param2;
         this._errorCode = param3;
      }
      
      public function get loginInfo() : LoginMSInfo
      {
         return this._loginInfo;
      }
      
      public function get errorCode() : String
      {
         return this._errorCode;
      }
   }
}

