package com.robot.app.cmd
{
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.CommandID;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserInfoManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class AdviceTeamMateCmdListener extends BaseBeanController
   {
      
      public function AdviceTeamMateCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.ADVICE_TEAMMATE,this.onAdviceHandler);
         finish();
      }
      
      public function onAdviceHandler(param1:SocketEvent) : void
      {
         var e:SocketEvent = param1;
         var by:ByteArray = e.data as ByteArray;
         var id:uint = by.readUnsignedInt();
         var teamid:uint = by.readUnsignedInt();
         if(MainManager.actorInfo.teamInfo.id == teamid)
         {
            UserInfoManager.getInfo(id,function(param1:UserInfo):void
            {
               ToolBarController.showBubble(param1.nick);
            });
         }
      }
   }
}

