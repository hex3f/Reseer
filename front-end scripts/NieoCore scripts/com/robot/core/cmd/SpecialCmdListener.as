package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.Direction;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class SpecialCmdListener extends BaseBeanController
   {
      
      public function SpecialCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.DANCE_ACTION,this.onSpecial);
         finish();
      }
      
      private function onSpecial(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         var _loc5_:String = Direction.indexToStr(_loc2_.readUnsignedInt());
         UserManager.dispatchAction(_loc3_,PeopleActionEvent.SPECIAL,_loc5_);
      }
   }
}

