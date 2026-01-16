package com.robot.core.teamInstallation
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.FortressItemXMLInfo;
   import com.robot.core.energyExchange.ExchangeItemInfo;
   import com.robot.core.energyExchange.ExchangeOreModel;
   import com.robot.core.info.team.ArmInfo;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   public class TeamInfoController
   {
      
      private static var _info:ArmInfo;
      
      private static var _teamId:uint;
      
      private static var _nexF:uint;
      
      private static var _workTime:int;
      
      private static var _donateTime:int;
      
      private static var _maxA:Array;
      
      private static var _needIdA:Array;
      
      private static var _curNumA:Array;
      
      private static var _workPanel:AppModel;
      
      private static var _teamLeaderApp:AppModel;
      
      private static var _memberApp:AppModel;
      
      private static var _matterListApp:AppModel;
      
      private static var _donateApp:AppModel;
      
      private static var _superPanel:AppModel;
      
      private static var _curSuperInfo:ExchangeItemInfo;
      
      public static var _isUpdata:uint = 0;
      
      public function TeamInfoController()
      {
         super();
      }
      
      public static function setRemainWorkTime() : void
      {
         --_workTime;
         ++MainManager.actorInfo.dailyResArr[10];
         if(_workTime < 0)
         {
            _workTime = 0;
         }
      }
      
      public static function get remainWorkTime() : uint
      {
         return _workTime;
      }
      
      public static function setRemainDonate(param1:uint) : void
      {
         _donateTime -= param1;
         MainManager.actorInfo.dailyResArr[11] += param1;
         if(_donateTime < 0)
         {
            _donateTime = 0;
         }
      }
      
      public static function get remainDonate() : uint
      {
         return _donateTime;
      }
      
      public static function get teamId() : uint
      {
         return _teamId;
      }
      
      public static function get nexForm() : uint
      {
         return _nexF;
      }
      
      public static function get info() : ArmInfo
      {
         return _info;
      }
      
      public static function start(param1:ArmInfo) : void
      {
         _info = param1;
         _workTime = 5 - MainManager.actorInfo.dailyResArr[10];
         _donateTime = 100 - MainManager.actorInfo.dailyResArr[11];
         if(_workTime < 0)
         {
            _workTime = 0;
         }
         if(_donateTime < 0)
         {
            _donateTime = 0;
         }
         SocketConnection.addCmdListener(CommandID.ARM_UP_GET_ONE_INFO,onComHandler);
         SocketConnection.send(CommandID.ARM_UP_GET_ONE_INFO,MainManager.actorInfo.teamInfo.id,_info.buyTime);
      }
      
      private static function onComHandler(param1:SocketEvent) : void
      {
         var _loc2_:int = 0;
         SocketConnection.removeCmdListener(CommandID.ARM_UP_GET_ONE_INFO,onComHandler);
         var _loc3_:ByteArray = param1.data as ByteArray;
         _teamId = _loc3_.readUnsignedInt();
         ArmInfo.setFor2967_2965(_info,_loc3_);
         _nexF = FortressItemXMLInfo.getNextForm(_info.id,_info.form);
         var _loc4_:Array = FortressItemXMLInfo.getResIDs(_info.id,_info.form);
         _maxA = FortressItemXMLInfo.getResMaxs(_info.id,_info.form);
         _needIdA = [];
         _curNumA = [];
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc2_ = 0;
            while(_loc2_ < _info.res.length)
            {
               if(_loc4_[_loc5_] != 0 && _loc4_[_loc5_] == _info.res.getKeys()[_loc2_])
               {
                  _needIdA.push(_loc4_[_loc5_]);
                  _curNumA.push(_info.res.getValues()[_loc2_]);
               }
               _loc2_++;
            }
            _loc5_++;
         }
         if(_info.form > 1)
         {
            if(_info.form < uint(FortressItemXMLInfo.getMaxLevel(_info.id)))
            {
               showMatterApp();
            }
            else
            {
               showMemberPanel();
            }
         }
         else
         {
            if(_info.res.getValues()[1] == 5000)
            {
               SocketConnection.addCmdListener(CommandID.ARM_UP_UPDATE,onUpHandler);
               SocketConnection.send(CommandID.ARM_UP_UPDATE,_info.buyTime,_nexF);
               return;
            }
            showWorkPanel();
         }
      }
      
      public static function canLevelUp(param1:Function) : void
      {
         var fun:Function = param1;
         SocketConnection.addCmdListener(CommandID.TEAM_GET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,arguments.callee);
            var _loc3_:SimpleTeamInfo = param1.data as SimpleTeamInfo;
            if(_loc3_.exp < _loc3_.countExp(_loc3_.level + 1))
            {
               fun(false);
            }
            else
            {
               fun(true);
            }
         });
         SocketConnection.send(CommandID.TEAM_GET_INFO,MainManager.actorInfo.teamInfo.id);
      }
      
      private static function onUpHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.ARM_UP_UPDATE,onUpHandler);
         SocketConnection.addCmdListener(CommandID.ARM_UP_GET_ONE_INFO,onComHandler);
         SocketConnection.send(CommandID.ARM_UP_GET_ONE_INFO,MainManager.actorInfo.teamInfo.id,_info.buyTime);
      }
      
      public static function destroy() : void
      {
         SocketConnection.removeCmdListener(CommandID.ARM_UP_GET_ONE_INFO,onComHandler);
         SocketConnection.removeCmdListener(CommandID.ARM_UP_UPDATE,onUpHandler);
         _info = null;
         if(Boolean(_workPanel))
         {
            _workPanel.destroy();
            _workPanel = null;
         }
         if(Boolean(_teamLeaderApp))
         {
            _teamLeaderApp.sharedEvents.removeEventListener(Event.CLOSE,onTeamLeaderHandler);
            _teamLeaderApp.destroy();
            _teamLeaderApp = null;
         }
         if(Boolean(_memberApp))
         {
            _memberApp.destroy();
            _memberApp = null;
         }
         if(Boolean(_matterListApp))
         {
            _matterListApp.destroy();
            _matterListApp = null;
         }
         if(Boolean(_donateApp))
         {
            _donateApp.destroy();
            _donateApp = null;
         }
         if(Boolean(_superPanel))
         {
            onCloseSuperHandler(null);
         }
      }
      
      public static function showWorkPanel() : void
      {
         if(!_workPanel)
         {
            _workPanel = new AppModel(ClientConfig.getAppModule("ConstructionProgressPanel"),"正在进入");
            _workPanel.setup();
         }
         _workPanel.init(_info);
         _workPanel.show();
      }
      
      private static function showTeamLeaderPanel() : void
      {
         if(!_teamLeaderApp)
         {
            _teamLeaderApp = new AppModel(ClientConfig.getAppModule("TeamLeaderCanSeePanel"),"正在进入");
            _teamLeaderApp.setup();
            _teamLeaderApp.sharedEvents.addEventListener(Event.CLOSE,onTeamLeaderHandler);
         }
         _teamLeaderApp.init(_info);
         _teamLeaderApp.show();
      }
      
      private static function onTeamLeaderHandler(param1:Event) : void
      {
         showMatterApp();
      }
      
      private static function showMemberPanel() : void
      {
         if(!_memberApp)
         {
            _memberApp = new AppModel(ClientConfig.getAppModule("MemberCanSeePanel"),"正在进入");
            _memberApp.setup();
         }
         _memberApp.init(_info);
         _memberApp.show();
      }
      
      private static function showMatterApp() : void
      {
         if(!_matterListApp)
         {
            _matterListApp = new AppModel(ClientConfig.getAppModule("NeedMatterListPanel"),"正在进入");
            _matterListApp.setup();
            _matterListApp.sharedEvents.addEventListener(Event.CLOSE,onCloseHandler);
         }
         _matterListApp.init(_info);
         _matterListApp.show();
      }
      
      private static function onCloseHandler(param1:Event) : void
      {
         canDonate();
      }
      
      private static function canDonate() : void
      {
         ExchangeOreModel.getData(onDataComHandler,"你目前没有可以捐献的物质。");
      }
      
      private static function onDataComHandler(param1:Object) : void
      {
         var _loc2_:HashMap = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(Boolean(param1))
         {
            _loc2_ = param1 as HashMap;
            _loc3_ = _loc2_.getValues();
            _loc4_ = new Array();
            _loc5_ = 0;
            while(_loc5_ < _needIdA.length)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc3_.length)
               {
                  if(_needIdA[_loc5_] == (_loc3_[_loc6_] as ExchangeItemInfo).itemId)
                  {
                     if(_curNumA[_loc5_] < _maxA[_loc5_])
                     {
                        _loc4_.push(_loc3_[_loc6_]);
                     }
                  }
                  if(_loc5_ == _needIdA.length - 1)
                  {
                     if((_loc3_[_loc6_] as ExchangeItemInfo).isSuper)
                     {
                        _loc4_.push(_loc3_[_loc6_]);
                     }
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
            if(_loc4_.length > 0)
            {
               showCanList(_loc4_);
            }
            else
            {
               Alarm.show("你没有该设施升级所需的物资可以捐献！");
            }
         }
      }
      
      private static function showCanList(param1:Array) : void
      {
         if(!_donateApp)
         {
            _donateApp = new AppModel(ClientConfig.getAppModule("DonateMatterListPanel"),"正在打开");
            _donateApp.setup();
            _donateApp.sharedEvents.addEventListener(Event.CLOSE,onCloseMatterListHandler);
            _donateApp.sharedEvents.addEventListener(Event.OPEN,onOpenMatterListHandler);
         }
         _donateApp.init(param1);
         _donateApp.show();
      }
      
      private static function onCloseMatterListHandler(param1:Event) : void
      {
         _donateApp.sharedEvents.removeEventListener(Event.CLOSE,onCloseMatterListHandler);
         _donateApp.sharedEvents.removeEventListener(Event.OPEN,onOpenMatterListHandler);
         _donateApp.destroy();
         _donateApp = null;
      }
      
      private static function onOpenMatterListHandler(param1:Event) : void
      {
         onCloseMatterListHandler(null);
         showSuperPanel();
      }
      
      private static function showSuperPanel() : void
      {
         if(!_superPanel)
         {
            _superPanel = new AppModel(ClientConfig.getAppModule("SuperDonateMatterPanel"),"正在打开");
            _superPanel.setup();
            _superPanel.sharedEvents.addEventListener(Event.CLOSE,onCloseSuperHandler);
         }
         _superPanel.init(_curSuperInfo);
         _superPanel.show();
      }
      
      private static function onCloseSuperHandler(param1:Event) : void
      {
         _superPanel.sharedEvents.removeEventListener(Event.CLOSE,onCloseSuperHandler);
         _superPanel.destroy();
         _superPanel = null;
      }
      
      public static function removeNum(param1:Array) : Array
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(param1[_loc2_] == 0)
            {
               param1.splice(_loc2_,1);
               _loc2_--;
            }
            _loc2_++;
         }
         return param1;
      }
      
      public static function get curSuperInfo() : ExchangeItemInfo
      {
         return _curSuperInfo;
      }
      
      public static function set curSuperInfo(param1:ExchangeItemInfo) : void
      {
         _curSuperInfo = param1;
      }
      
      public static function get needIdA() : Array
      {
         return _needIdA;
      }
      
      public static function get curNumA() : Array
      {
         return _curNumA;
      }
      
      public static function get maxA() : Array
      {
         return _maxA;
      }
   }
}

