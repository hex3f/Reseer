package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.info.ChangeClothInfo;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class ChangeClothCmdListener extends BaseBeanController
   {
      
      public function ChangeClothCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.CHANGE_CLOTH,this.onChange);
         finish();
      }
      
      private function onChange(param1:SocketEvent) : void
      {
         var _loc2_:ChangeClothInfo = param1.data as ChangeClothInfo;
         UserManager.dispatchAction(_loc2_.userID,PeopleActionEvent.CLOTH_CHANGE,_loc2_.clothArray);
      }
   }
}

