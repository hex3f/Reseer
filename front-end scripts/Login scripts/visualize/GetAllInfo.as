package visualize
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.utils.ByteArray;
   import loginStrategy.EmailLogin;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import others.CommendSvrInfo;
   import others.LoginMSInfo;
   import tip.TipPanel;
   
   public class GetAllInfo extends Sprite
   {
      
      private var goShipBtn:SimpleButton;
      
      private var getAllIf:getPPAllInfo;
      
      private var slefColth:NameAndColthing;
      
      private var svr:ServerList;
      
      public function GetAllInfo(param1:NameAndColthing)
      {
         super();
         this.slefColth = param1;
         this.getAllIf = new getPPAllInfo();
         this.getAllIf.x = 0;
         this.getAllIf.y = 0;
         addChild(this.getAllIf);
         this.getAllIf["bgMc"].visible = false;
         this.getAllIf.miIdtxt.text = Login.loginRoot.lp.miId;
         if(Login.loginRoot.lp.emailLog)
         {
            this.getAllIf.miIdtxt.text = EmailLogin.eamilUserId.toString();
         }
         if(Login.isSession)
         {
            this.getAllIf.miIdtxt.text = SocketConnection.mainSocket.userID.toString();
            this.getAllIf.pwdTxt.text = "";
         }
         else if(Login.isExternal)
         {
            this.getAllIf.miIdtxt.text = Login.UID.toString();
            this.getAllIf.pwdTxt.text = "";
         }
         else
         {
            this.getAllIf.pwdTxt.text = Login.loginRoot.lp.password;
         }
         this.getAllIf.robotTxt.text = NameAndColthing.robotId;
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = NameAndColthing.getColor();
         this.getAllIf.color.transform.colorTransform = _loc2_;
         this.goShipBtn = this.getAllIf.goShipBtn;
         this.getAllIf.robotTxt.addEventListener(Event.CHANGE,this.onTexChangeHandler);
         this.getAllIf.robotTxt.addEventListener(FocusEvent.FOCUS_IN,this.onTxtFocusInHandler);
         this.goShipBtn.addEventListener(MouseEvent.CLICK,this.goToShip);
         EventManager.addEventListener("name_error",this.onErrorHandler);
      }
      
      private function onErrorHandler(param1:Event) : void
      {
         this.getAllIf["bgMc"].visible = true;
      }
      
      private function onTxtFocusInHandler(param1:FocusEvent) : void
      {
         this.getAllIf["bgMc"].visible = false;
      }
      
      private function onTexChangeHandler(param1:Event) : void
      {
         var e:Event = param1;
         var niBy:ByteArray = new ByteArray();
         niBy.writeUTFBytes(this.getAllIf.robotTxt.text);
         if(niBy.length > 16)
         {
            TipPanel.createTipPanel("输入的文字太长了",function():void
            {
            });
            this.getAllIf["bgMc"].visible = true;
            return;
         }
      }
      
      private function goBack(param1:MouseEvent) : void
      {
         this.slefColth.visible = true;
         this.visible = false;
      }
      
      private function goToShip(param1:MouseEvent) : void
      {
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,this.onConnectPP);
         if(LoginStatus.isHttp)
         {
            trace("GetAllInfo.as -- > login by http");
            SocketConnection.mainSocket.connect(LoginStatus.HTTP_IP,LoginStatus.HTTP_PORT);
         }
         else
         {
            trace("GetAllInfo.as -- > login by NORMAL");
            SocketConnection.mainSocket.connect(ClientConfig.SUB_SERVER_IP,ClientConfig.SUB_SERVER_PORT);
         }
      }
      
      private function onConnectPP(param1:Event) : void
      {
         var color:uint = 0;
         var code:uint = 0;
         var e:Event = param1;
         var niBy:ByteArray = new ByteArray();
         niBy.writeUTFBytes(this.getAllIf.robotTxt.text);
         if(niBy.length > 16)
         {
            TipPanel.createTipPanel("输入的文字太长了",function():void
            {
            });
            return;
         }
         niBy.length = 16;
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,this.onConnectPP);
         SocketConnection.addCmdListener(CommandID.CREATE_ROLE,this.roleCreate);
         trace(SocketConnection.mainSocket.userID.toString());
         color = NameAndColthing.getColor();
         code = SeerVerify.verifyCode;
         SocketConnection.send(CommandID.CREATE_ROLE,SocketConnection.mainSocket.userID,niBy,color);
      }
      
      private function roleCreate(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.CREATE_ROLE,this.roleCreate);
         if(param1.headInfo.result == 0)
         {
            SocketConnection.addCmdListener(CommandID.COMMEND_ONLINE,this.getCommendList);
            SocketConnection.send(CommandID.COMMEND_ONLINE,LoginMSInfo.session,MainManager.CHANNEL);
            this.visible = false;
         }
      }
      
      private function getCommendList(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.COMMEND_ONLINE,this.getCommendList);
         var _loc2_:CommendSvrInfo = param1.data as CommendSvrInfo;
         this.svr = new ServerList(_loc2_);
         this.svr.x = 49;
         this.svr.y = 54;
         Login.loginRoot.addChild(this.svr);
      }
   }
}

