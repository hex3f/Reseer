package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class SetTitleCmdListener extends BaseBeanController
   {
      
      public function SetTitleCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.SETTITLE,this.onSetTitle);
         finish();
      }
      
      private function onSetTitle(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         UserManager.dispatchAction(_loc3_,PeopleActionEvent.SET_TITLE,_loc4_);
      }
   }
}

