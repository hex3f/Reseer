package
{
   import com.robot.core.CommandID;
   import com.robot.core.controller.SaveUserInfo;
   import com.robot.core.net.SocketConnection;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.IDataInput;
   import login.AgainLoginPanel;
   import login.LoginPanel;
   import loginStrategy.*;
   import org.taomee.events.SocketErrorEvent;
   import org.taomee.net.SocketDispatcher;
   import org.taomee.tmf.TMF;
   import org.taomee.utils.DisplayUtil;
   import others.CommendSvrInfo;
   import others.LoginMSInfo;
   import others.RangeSvrInfo;
   import register.RegisterManage;
   import tip.TipPanel;
   import visualize.ParseLoginSocketError;
   
   public class Login extends Sprite
   {
      
      private static var _root:Login;
      
      public static var bg1:inBgMC;
      
      public static var isVip:Boolean;
      
      public static var isExternal:Boolean;
      
      public static var isSession:Boolean;
      
      public static var UID:uint;
      
      public static var PSW:String;
      
      public static var bSavaMi:Boolean = false;
      
      public static var pwd:String = "";
      
      public static var loginSuccess:String = "loginSuccess";
      
      public var lp:LoginPanel;
      
      private var reg:RegisterManage;
      
      private var agLoginP:AgainLoginPanel;
      
      public var svrObj:Object = new Object();
      
      private var firstPage:MovieClip;
      
      private var startBtn:SimpleButton;
      
      private var parentBtn:SimpleButton;
      
      private var newLoginBtn:SimpleButton;
      
      private var parentMC:MovieClip;
      
      private var addBtn:SimpleButton;
      
      public function Login()
      {
         super();
         soundmanger.getInstance().playBgMusic();
         addEventListener(Event.ADDED_TO_STAGE,this.onAdded);
         var _loc1_:inBgMC = new inBgMC();
         _loc1_.x = 0;
         _loc1_.y = 0;
         addChild(_loc1_);
         bg1 = _loc1_;
         _root = this;
         this.firstPage = new FirstPageMC();
         this.startBtn = this.firstPage["startBtn"];
         this.newLoginBtn = this.firstPage["loginBtn"];
         this.addBtn = this.firstPage["addBtn"];
         this.parentBtn = this.firstPage["parentBtn"];
         this.startBtn.addEventListener(MouseEvent.CLICK,this.onNewLogin);
         this.newLoginBtn.addEventListener(MouseEvent.CLICK,this.startNewLogin);
         this.parentBtn.addEventListener(MouseEvent.CLICK,this.showParent);
         this.addBtn.addEventListener(MouseEvent.CLICK,this.addHandler);
         TMF.registerClass(CommandID.RANGE_ONLINE,RangeSvrInfo);
         TMF.registerClass(CommandID.MAIN_LOGIN_IN,LoginMSInfo);
         TMF.registerClass(CommandID.COMMEND_ONLINE,CommendSvrInfo);
         SocketDispatcher.getInstance().addEventListener(SocketErrorEvent.ERROR,onError);
      }
      
      private static function onError(param1:SocketErrorEvent) : void
      {
         if(param1.headInfo.result == 5005)
         {
            loginRoot.lp.createroleFun();
         }
         else
         {
            ParseLoginSocketError.parse(param1.headInfo.result);
         }
      }
      
      public static function dispatch(param1:String, param2:String, param3:IDataInput) : void
      {
         if(Boolean(_root.lp))
         {
            _root.lp.destroy();
         }
         _root.svrObj.ip = param1;
         _root.svrObj.port = param2;
         _root.svrObj.userID = SocketConnection.mainSocket.userID;
         _root.svrObj.friendData = param3;
         _root.svrObj.session = LoginMSInfo.session;
         _root.svrObj.bSavaMi = Login.bSavaMi;
         _root.svrObj.pwd = Login.pwd;
         _root.dispatchEvent(new Event(loginSuccess));
         _root.destroy();
         SocketDispatcher.getInstance().removeEventListener(SocketErrorEvent.ERROR,onError);
      }
      
      public static function get loginRoot() : Login
      {
         return _root;
      }
      
      private function onAdded(param1:Event) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:URLLoader = null;
         if(ExternalInterface.available)
         {
            isSession = true;
            _loc2_ = ExternalInterface.call("getSessionID");
            if(_loc2_ != null && _loc2_ != "")
            {
               isExternal = false;
               this.lp = new LoginPanel();
            }
            else
            {
               isSession = false;
               isExternal = false;
               addChild(this.firstPage);
            }
         }
         else
         {
            isSession = false;
            _loc3_ = this.stage.loaderInfo.parameters;
            if(uint(_loc3_.sign) == 1)
            {
               isExternal = true;
               _loc4_ = new URLLoader();
               _loc4_.addEventListener(Event.COMPLETE,this.onLoadSession);
               _loc4_.load(new URLRequest("http://192.168.0.146/?c=account&d=getSign&sid=" + _loc3_.sid));
            }
            else
            {
               isExternal = false;
               addChild(this.firstPage);
            }
         }
      }
      
      private function onLoadSession(param1:Event) : void
      {
         var _loc2_:XML = XML(param1.target.data);
         var _loc3_:uint = uint(_loc2_.item.@uid);
         var _loc4_:String = _loc2_.item.@pass;
         if(_loc3_ != 0)
         {
            this.lp = new LoginPanel();
            this.lp.addEventListener("BACK",this.onRemoved);
            this.lp.externalLogin(_loc3_,_loc4_);
            UID = _loc3_;
            PSW = _loc4_;
         }
         else
         {
            isExternal = false;
            addChild(this.firstPage);
         }
      }
      
      private function onRemoved(param1:Event) : void
      {
         DisplayUtil.removeForParent(this.lp);
         this.showLogin();
      }
      
      private function addHandler(param1:MouseEvent) : void
      {
         ExternalInterface.call("addBookmark","赛尔号 - 英勇赛尔，智慧童年","http://seer.61.com");
      }
      
      private function onNewLogin(param1:MouseEvent) : void
      {
         this.createLogin(true);
         this.removeStart();
      }
      
      private function showParent(param1:MouseEvent) : void
      {
         if(!this.parentMC)
         {
            this.parentMC = new ParentsMC();
         }
         addChild(this.parentMC);
      }
      
      private function showLogin() : void
      {
         var _loc1_:Array = SaveUserInfo.getUserInfo();
         if(_loc1_ != null && _loc1_.length != 0)
         {
            this.agLoginP = new AgainLoginPanel(_loc1_);
            this.agLoginP.x = 10;
            this.agLoginP.y = 71;
            addChild(this.agLoginP);
         }
         else
         {
            this.createLogin(true);
         }
      }
      
      private function startHandler(param1:MouseEvent = null) : void
      {
         TipPanel.createTipPanel("获取时空船票即可获得进入资格，快去赛尔号活动页面抽取船票吧！");
      }
      
      private function startNewLogin(param1:MouseEvent) : void
      {
         this.createLogin(true);
         this.removeStart();
      }
      
      private function destroy() : void
      {
         var _loc1_:DisplayObject = null;
         for each(_loc1_ in Login.loginRoot)
         {
            _loc1_.parent.removeChild(_loc1_);
            _loc1_ = null;
         }
         this.agLoginP = null;
         this.lp = null;
         _root = null;
         bg1 = null;
      }
      
      private function removeStart() : void
      {
         DisplayUtil.removeForParent(this.firstPage);
         this.startBtn.removeEventListener(MouseEvent.CLICK,this.startHandler);
         this.newLoginBtn.removeEventListener(MouseEvent.CLICK,this.startNewLogin);
         this.parentBtn.removeEventListener(MouseEvent.CLICK,this.showParent);
         this.addBtn.removeEventListener(MouseEvent.CLICK,this.addHandler);
         this.firstPage = null;
         this.startBtn = null;
         this.newLoginBtn = null;
      }
      
      public function createLogin(param1:Boolean) : void
      {
         this.lp = new LoginPanel();
         this.lp.addEventListener("BACK",this.onRemoved);
         this.lp.x = 195;
         this.lp.y = 45;
         addChild(this.lp);
         this.lp.regBtn.addEventListener(MouseEvent.CLICK,this.onRegister);
      }
      
      private function onRegister(param1:MouseEvent) : void
      {
         Login.bSavaMi = false;
         Login.pwd = "";
         this.lp.visible = false;
         this.lp.logMain.savaMiTip.visible = false;
         this.lp.logMain.savaPwdTip.visible = false;
         this.reg = new RegisterManage();
         this.reg.x = 231;
         this.reg.y = 87;
         addChild(this.reg);
      }
   }
}

