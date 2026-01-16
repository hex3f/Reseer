package com.robot.core.cmd.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.event.NonoActionEvent;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class OnOffCmdListener extends BaseBeanController
   {
      
      public function OnOffCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_CLOSE_OPEN,this.onChanged);
         finish();
      }
      
      private function onChanged(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:Boolean = Boolean(_loc2_.readUnsignedInt());
         NonoManager.dispatchAction(_loc3_,NonoActionEvent.CLOSE_OPEN,_loc4_);
      }
   }
}

