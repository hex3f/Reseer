package com.robot.app.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class TranUserCmdListener extends BaseBeanController
   {
      
      public function TranUserCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.NOTE_TRANSFORM_USER,this.onTran);
         finish();
      }
      
      private function onTran(param1:SocketEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:uint = _loc3_.readUnsignedInt();
         var _loc6_:uint = _loc3_.readUnsignedInt();
         if(_loc4_ == MainManager.actorID)
         {
            _loc2_ = MainManager.actorModel;
         }
         else
         {
            _loc2_ = UserManager.getUserModel(_loc4_);
         }
         if(Boolean(_loc2_))
         {
         }
      }
   }
}

