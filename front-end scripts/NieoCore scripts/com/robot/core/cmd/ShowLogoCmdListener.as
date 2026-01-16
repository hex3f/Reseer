package com.robot.core.cmd
{
   import com.robot.core.CommandID;
   import com.robot.core.info.team.TeamLogoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.teamInstallation.TeamInfoManager;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class ShowLogoCmdListener extends BaseBeanController
   {
      
      private var _isShow:uint;
      
      private var _uid:uint;
      
      public function ShowLogoCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_SHOW_LOGO,this.onShowComHandler);
         finish();
      }
      
      private function onShowComHandler(param1:SocketEvent) : void
      {
         var _loc2_:BasePeoleModel = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         this._uid = _loc3_.readUnsignedInt();
         this._isShow = _loc3_.readUnsignedInt();
         if(this._uid == MainManager.actorInfo.userID)
         {
            MainManager.actorInfo.teamInfo.isShow = Boolean(this._isShow);
         }
         else
         {
            _loc2_ = UserManager.getUserModel(this._uid);
            _loc2_.info.teamInfo.isShow = Boolean(this._isShow);
         }
         this.setLogo(this._uid,Boolean(this._isShow));
      }
      
      private function setLogo(param1:uint, param2:Boolean) : void
      {
         var uid:uint = param1;
         var isShow:Boolean = param2;
         TeamInfoManager.getTeamLogoInfo(uid,function(param1:TeamLogoInfo):void
         {
            var _loc2_:BasePeoleModel = null;
            if(uid == MainManager.actorID)
            {
               _loc2_ = MainManager.actorModel;
            }
            else
            {
               _loc2_ = UserManager.getUserModel(uid);
            }
            if(Boolean(_loc2_))
            {
               if(isShow)
               {
                  _loc2_.showTeamLogo(param1);
               }
               else
               {
                  _loc2_.removeTeamLogo();
               }
            }
         });
      }
   }
}

