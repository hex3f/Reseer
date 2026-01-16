package com.robot.app.team
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import org.taomee.events.SocketEvent;
   
   public class SuperCoreController
   {
      
      private static var _teamInfo:SimpleTeamInfo;
      
      private static var _panelOne:AppModel;
      
      private static var _panelTwo:AppModel;
      
      private static var _conFun:Function;
      
      private static var _arr:Array = [];
      
      public function SuperCoreController()
      {
         super();
      }
      
      public static function start() : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_GET_INFO,onComHandler);
         SocketConnection.send(CommandID.TEAM_GET_INFO,MainManager.actorInfo.teamInfo.id);
      }
      
      public static function get teamInfo() : SimpleTeamInfo
      {
         return _teamInfo;
      }
      
      private static function onComHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,onComHandler);
         _teamInfo = param1.data as SimpleTeamInfo;
         var _loc2_:uint = uint(_teamInfo.superCoreNum);
         if(_loc2_ >= 10)
         {
            addPanelTwo(_loc2_);
         }
         else
         {
            addPanelOne(_loc2_);
         }
      }
      
      public static function destroy() : void
      {
         _arr = [];
         if(Boolean(_panelOne))
         {
            _panelOne.destroy();
            _panelOne = null;
         }
         if(Boolean(_panelTwo))
         {
            _panelTwo.destroy();
            _panelTwo = null;
         }
         _conFun = null;
         SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,onComHandler);
         SocketConnection.removeCmdListener(CommandID.TEAM_GIVE_SUPER_CORE,onSendHandler);
      }
      
      private static function addPanelOne(param1:uint) : void
      {
         if(!_panelOne)
         {
            _panelOne = new AppModel(ClientConfig.getAppModule("SuperCoreDonatePanel"),"正在进入");
            _panelOne.setup();
         }
         _panelOne.init(param1);
         _panelOne.show();
      }
      
      private static function addPanelTwo(param1:uint) : void
      {
         if(!_panelTwo)
         {
            _panelTwo = new AppModel(ClientConfig.getAppModule("SuperCoreDonateTwoPanel"),"正在进入");
            _panelTwo.setup();
         }
         _panelTwo.init(param1);
         _panelTwo.show();
      }
      
      public static function removeTwoPanel() : void
      {
         if(Boolean(_panelTwo))
         {
            _panelTwo.hide();
         }
      }
      
      public static function addCallback(param1:Function) : void
      {
         _arr.push(param1);
      }
      
      public static function send(param1:Function = null) : void
      {
         _conFun = param1;
         if(Boolean(MainManager.actorModel.nono) && Boolean(MainManager.actorInfo.superNono))
         {
            SocketConnection.addCmdListener(CommandID.TEAM_GIVE_SUPER_CORE,onSendHandler);
            SocketConnection.send(CommandID.TEAM_GIVE_SUPER_CORE);
         }
         else
         {
            NpcTipDialog.show("(≧▽≦)/ 为战队充能要带上超能NoNo哦！",null,NpcTipDialog.NONO_2);
         }
      }
      
      private static function onSendHandler(param1:SocketEvent) : void
      {
         var e:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.TEAM_GIVE_SUPER_CORE,onSendHandler);
         ++_teamInfo.superCoreNum;
         Alarm.show("O(∩_∩)O耶，充能成功咯，你为战队提供了10个单位的超级能量！");
         if(_conFun != null)
         {
            _conFun();
         }
         _arr.forEach(function(param1:Function, param2:int, param3:Array):void
         {
            param1(_teamInfo.superCoreNum);
         });
      }
      
      public static function showLogo(param1:uint) : void
      {
         SocketConnection.send(CommandID.TEAM_SHOW_LOGO,param1);
      }
   }
}

