package com.robot.app.task
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.app.petItem.StudyUpManager;
   import com.robot.app.spt.PioneerTaskIconController;
   import com.robot.app.sptGalaxy.*;
   import com.robot.app.task.SeerInstructor.NewInstructorContoller;
   import com.robot.app.task.conscribeTeam.ConscribeTeam;
   import com.robot.app.task.control.TaskController_25;
   import com.robot.app.task.dailyTask.DailyTaskController;
   import com.robot.app.task.newNovice.NewNoviceGuideTaskController;
   import com.robot.app.task.publicizeenvoy.PublicizeEnvoyIconControl;
   import com.robot.app.tasksRecord.TasksRecordController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.ExchangeInfo;
   import com.robot.core.manager.HatchTaskMapManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NpcController;
   import com.robot.core.teamPK.TeamPKManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class TaskMain extends BaseBeanController
   {
      
      private var _iconMc:MovieClip;
      
      private var _achieveIconMc:MovieClip;
      
      private var _panel:AppModel;
      
      private var _achievePanel:AppModel;
      
      public function TaskMain()
      {
         super();
      }
      
      override public function start() : void
      {
         PioneerTaskIconController.createIcon();
         DailyTaskController.setup();
         TasksRecordController.setup();
         NewInstructorContoller.setup();
         ConscribeTeam.setup();
         TaskController_25.start();
         EventManager.addEventListener("DS_TASK",this.onDsTask);
         if(MainManager.actorInfo.teamPKInfo.homeTeamID > 50000)
         {
            TeamPKManager.showIcon();
         }
         this.CreateFightExchangeIcon();
         finish();
         AutomaticFightManager.setup();
         StudyUpManager.setup();
         HatchTaskMapManager.setup();
         NewNoviceGuideTaskController.setup();
         NpcController.setup();
         XuanWuController.setup();
         SocketConnection.addCmdListener(CommandID.GET_EXCHANGE_INFO,this.getExchangeInfo);
         SocketConnection.send(CommandID.GET_EXCHANGE_INFO);
      }
      
      public function getExchangeInfo(param1:SocketEvent) : void
      {
         var _loc4_:ExchangeInfo = null;
         SocketConnection.removeCmdListener(CommandID.GET_EXCHANGE_INFO,this.getExchangeInfo);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = new ExchangeInfo(_loc2_);
            if(_loc4_._exchangeNum >= 999)
            {
               _loc4_._exchangeNum = 999;
            }
            MainManager.ExchangeInfoList.push(_loc4_);
            _loc5_++;
         }
      }
      
      private function onDsTask(param1:DynamicEvent) : void
      {
         MainManager.actorInfo.newInviteeCnt = uint(param1.paramObject);
         if(MainManager.actorInfo.newInviteeCnt >= 2)
         {
            PublicizeEnvoyIconControl.lightIcon();
         }
      }
      
      private function CreateFightExchangeIcon() : void
      {
         this._iconMc = TaskIconManager.getIcon("ReadyForWar_Icon") as MovieClip;
         ToolTipManager.add(this._iconMc,"荣誉兑换手册");
         TaskIconManager.addIcon(this._iconMc);
         (this._iconMc["light_mc"] as MovieClip).visible = false;
         this._iconMc.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            if(!_panel)
            {
               _panel = new AppModel(ClientConfig.getAppModule("FightExchangePanel"),"正在加载兑换手册....");
               _panel.setup();
            }
            _panel.show();
         });
      }
      
      private function CreateAchievePanel() : void
      {
         this._achieveIconMc = TaskIconManager.getIcon("PublicizeEnloy_ICON") as MovieClip;
         ToolTipManager.add(this._achieveIconMc,"赛尔成就档案");
         TaskIconManager.addIcon(this._achieveIconMc);
         this._achieveIconMc.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            if(!_achievePanel)
            {
               _achievePanel = new AppModel(ClientConfig.getAppModule("AchieveNewPanel"),"正在加载赛尔成就档案....");
               _achievePanel.setup();
            }
            _achievePanel.show();
         });
      }
   }
}

