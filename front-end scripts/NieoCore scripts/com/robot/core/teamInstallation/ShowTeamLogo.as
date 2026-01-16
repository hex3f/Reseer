package com.robot.core.teamInstallation
{
   import com.robot.core.cmd.UserListCmdListener;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.event.TeamEvent;
   import com.robot.core.info.team.TeamLogoInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.BasePeoleModel;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.ds.HashMap;
   import org.taomee.manager.EventManager;
   
   public class ShowTeamLogo extends BaseBeanController
   {
      
      private static var owner:ShowTeamLogo;
      
      private var timer:Timer;
      
      private var userList:Array;
      
      private var hashMap:HashMap = new HashMap();
      
      private var people:BasePeoleModel;
      
      public function ShowTeamLogo()
      {
         super();
         owner = this;
      }
      
      public static function showLogo(param1:BasePeoleModel) : void
      {
         if(Boolean(owner))
         {
            owner._showLogo(param1);
         }
      }
      
      override public function start() : void
      {
         EventManager.addEventListener(RobotEvent.FILTER_SUPER_TEAM,this.onCreatedMapUser);
         EventManager.addEventListener(TeamEvent.MODIFY_LOGO,this.onModifyLogo);
         finish();
      }
      
      private function onModifyLogo(param1:TeamEvent) : void
      {
         if(!MainManager.actorInfo.teamInfo.isShow)
         {
            return;
         }
         var _loc2_:uint = MainManager.actorInfo.teamInfo.id;
      }
      
      private function onCreatedMapUser(param1:RobotEvent) : void
      {
         this.getTeamLogo(UserListCmdListener.superList);
      }
      
      public function getTeamLogo(param1:Array) : void
      {
         if(!this.timer)
         {
            this.timer = new Timer(1800000);
            this.timer.addEventListener(TimerEvent.TIMER,this.clearData);
            this.timer.start();
         }
         this.userList = param1.slice();
         this.load();
      }
      
      private function load() : void
      {
         var uid:uint = 0;
         var teamID:uint = 0;
         teamID = 0;
         if(this.userList.length == 0)
         {
            return;
         }
         uid = uint(this.userList.shift());
         if(uid == MainManager.actorID)
         {
            this.people = MainManager.actorModel;
         }
         else
         {
            this.people = UserManager.getUserModel(uid);
         }
         if(!this.people.info.teamInfo)
         {
            this.load();
            return;
         }
         teamID = this.people.info.teamInfo.id;
         if(teamID == 0)
         {
            this.load();
            return;
         }
         if(!this.hashMap.containsKey(teamID))
         {
            TeamInfoManager.getTeamLogoInfo(this.people.info.userID,function(param1:TeamLogoInfo):void
            {
               hashMap.add(teamID,param1);
               people.showTeamLogo(param1);
               load();
            });
         }
         else
         {
            this.people.showTeamLogo(this.hashMap.getValue(teamID));
            this.load();
         }
      }
      
      private function clearData(param1:TimerEvent) : void
      {
         this.hashMap.clear();
         this.hashMap = new HashMap();
      }
      
      public function _showLogo(param1:BasePeoleModel) : void
      {
         if(!param1.info.teamInfo)
         {
            return;
         }
         var _loc2_:uint = param1.info.teamInfo.id;
         if(_loc2_ == 0)
         {
            return;
         }
         var _loc3_:TeamLogoInfo = new TeamLogoInfo();
         _loc3_.logoBg = param1.info.teamInfo.logoBg;
         _loc3_.logoColor = param1.info.teamInfo.logoColor;
         _loc3_.logoIcon = param1.info.teamInfo.logoIcon;
         _loc3_.txtColor = param1.info.teamInfo.txtColor;
         _loc3_.logoWord = param1.info.teamInfo.logoWord;
         param1.showTeamLogo(_loc3_);
      }
   }
}

