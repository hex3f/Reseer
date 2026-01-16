package com.robot.core.teamInstallation
{
   import com.robot.core.CommandID;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.info.team.TeamLogoInfo;
   import com.robot.core.net.SocketConnection;
   import org.taomee.events.SocketEvent;
   
   public class TeamInfoManager
   {
      
      public function TeamInfoManager()
      {
         super();
      }
      
      public static function getSimpleTeamInfo(param1:uint, param2:Function = null) : void
      {
         var id:uint = param1;
         var fun:Function = param2;
         SocketConnection.addCmdListener(CommandID.TEAM_GET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,arguments.callee);
            var _loc3_:SimpleTeamInfo = param1.data as SimpleTeamInfo;
            if(fun != null)
            {
               fun(_loc3_);
            }
         });
         SocketConnection.send(CommandID.TEAM_GET_INFO,id);
      }
      
      public static function getTeamLogoInfo(param1:uint, param2:Function = null) : void
      {
         var uid:uint = param1;
         var fun:Function = param2;
         SocketConnection.addCmdListener(CommandID.TEAM_GET_LOGO_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.TEAM_GET_LOGO_INFO,arguments.callee);
            var _loc3_:TeamLogoInfo = param1.data as TeamLogoInfo;
            if(fun != null)
            {
               fun(_loc3_);
            }
         });
         SocketConnection.send(CommandID.TEAM_GET_LOGO_INFO,uid);
      }
   }
}

