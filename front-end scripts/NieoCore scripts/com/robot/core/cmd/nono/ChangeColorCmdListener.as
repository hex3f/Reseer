package com.robot.core.cmd.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.event.NonoActionEvent;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class ChangeColorCmdListener extends BaseBeanController
   {
      
      public function ChangeColorCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_CHANGE_COLOR,this.onChange);
         finish();
      }
      
      private function onChange(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         NonoManager.dispatchAction(_loc3_,NonoActionEvent.COLOR_CHANGE,_loc4_);
      }
   }
}

