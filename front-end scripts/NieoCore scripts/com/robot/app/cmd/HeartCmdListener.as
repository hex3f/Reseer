package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class HeartCmdListener extends BaseBeanController
   {
      
      public function HeartCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NIEO_HEART,this.onHeartHandler);
         finish();
      }
      
      private function onHeartHandler(param1:SocketEvent) : void
      {
         SocketConnection.send(CommandID.NIEO_HEART);
      }
   }
}

