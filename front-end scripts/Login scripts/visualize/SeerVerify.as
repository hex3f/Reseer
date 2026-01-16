package visualize
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.tmf.HeadInfo;
   import tip.TipPanel;
   
   public class SeerVerify
   {
      
      private static var _headerInfo:HeadInfo;
      
      public static var SEER_VERIFY_OK:String = "seerVerifyOk";
      
      public static var verifyCode:uint = 0;
      
      public function SeerVerify()
      {
         super();
      }
      
      public static function start(param1:String) : void
      {
         SocketConnection.mainSocket.addEventListener(Event.CONNECT,onConnect);
         SocketConnection.mainSocket.connect(ClientConfig.REGIST_IP,ClientConfig.REGIST_PORT);
         verifyCode = uint(param1);
      }
      
      private static function onConnect(param1:Event) : void
      {
         SocketConnection.mainSocket.removeEventListener(Event.CONNECT,onConnect);
         SocketConnection.mainSocket.userID = verifyCode;
         EventManager.dispatchEvent(new Event(SEER_VERIFY_OK));
      }
      
      private static function onSeer(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.SEER_VERIFY,onSeer);
         _headerInfo = param1.headInfo;
         if(_headerInfo.result == 0)
         {
            EventManager.dispatchEvent(new Event(SEER_VERIFY_OK));
         }
         else
         {
            TipPanel.createTipPanel("邀请码有误，请重新输入。");
         }
      }
   }
}

