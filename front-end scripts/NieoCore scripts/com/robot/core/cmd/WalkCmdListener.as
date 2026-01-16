package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class WalkCmdListener extends BaseBeanController
   {
      
      public function WalkCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.PEOPLE_WALK,this.onWalk);
         finish();
      }
      
      private function onWalk(param1:SocketEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = param1.data as ByteArray;
         _loc4_.position = 0;
         var _loc5_:uint = _loc4_.readUnsignedInt();
         var _loc6_:uint = _loc4_.readUnsignedInt();
         var _loc7_:Point = new Point(_loc4_.readUnsignedInt(),_loc4_.readUnsignedInt());
         if(_loc6_ != MainManager.actorInfo.userID)
         {
            _loc2_ = 0;
            if(_loc2_ == 0)
            {
               UserManager.dispatchAction(_loc6_,PeopleActionEvent.WALK,_loc7_);
            }
            else
            {
               _loc3_ = new ByteArray();
               _loc4_.readBytes(_loc3_,0,_loc2_);
               UserManager.dispatchAction(_loc6_,PeopleActionEvent.WALK,_loc3_.readObject());
            }
         }
      }
   }
}

