package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class TestCmdListener extends BaseBeanController
   {
      
      public function TestCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.TEST,this.onTest);
         finish();
      }
      
      private function onTest(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
      }
   }
}

