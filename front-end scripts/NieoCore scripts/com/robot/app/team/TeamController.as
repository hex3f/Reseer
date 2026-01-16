package com.robot.app.team
{
   import com.robot.app.im.TeamChatController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.info.team.TeamAddInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.MapType;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TeamController
   {
      
      private static var infoPanel:AppModel;
      
      private static var panel:AppModel;
      
      private static var searchPanel:MovieClip;
      
      private static var subMenu:MovieClip;
      
      public static const ADMIN:uint = 0;
      
      public static const MEMBER:uint = 1;
      
      public static const GUEST:uint = 2;
      
      public static const TEAM_INTEREST:Array = ["团结朋友","探索宇宙","精灵对战","对抗坏蛋","结识伙伴","维护正义","热爱自然","辛勤劳动","勤奋学习","公平竞争"];
      
      public static const ADMIN_STR:Array = ["指挥官","主将","副将","中坚","先锋","队员"];
      
      public function TeamController()
      {
         super();
      }
      
      public static function showSubMenu(param1:DisplayObject) : void
      {
         var _loc2_:Point = null;
         var _loc3_:SimpleButton = null;
         var _loc4_:SimpleButton = null;
         if(!subMenu)
         {
            subMenu = UIManager.getMovieClip("ui_teamBtnsPanel");
            _loc2_ = param1.localToGlobal(new Point());
            subMenu.x = _loc2_.x;
            subMenu.y = _loc2_.y - subMenu.height - 5;
            _loc3_ = subMenu["enterTeamBtn"];
            _loc4_ = subMenu["teamImBtn"];
            ToolTipManager.add(_loc3_,"进入要塞");
            ToolTipManager.add(_loc4_,"战队通迅");
            _loc3_.addEventListener(MouseEvent.CLICK,enterHandler);
            _loc4_.addEventListener(MouseEvent.CLICK,imHandler);
         }
         LevelManager.topLevel.addChild(subMenu);
         MainManager.getStage().addEventListener(MouseEvent.CLICK,onStageClick);
      }
      
      private static function onStageClick(param1:MouseEvent) : void
      {
         MainManager.getStage().removeEventListener(MouseEvent.CLICK,onStageClick);
         if(!subMenu.hitTestPoint(param1.stageX,param1.stageY))
         {
            DisplayUtil.removeForParent(subMenu);
         }
      }
      
      private static function enterHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(subMenu);
         show();
      }
      
      private static function imHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(subMenu);
         TeamChatController.show();
      }
      
      public static function show(param1:uint = 0) : void
      {
         var _loc2_:* = 0;
         if(param1 == 0)
         {
            _loc2_ = uint(MainManager.actorInfo.teamInfo.id);
         }
         else
         {
            _loc2_ = param1;
         }
         if(_loc2_ == 0)
         {
            searchTeam();
            return;
         }
         enter(_loc2_);
      }
      
      public static function searchTeam() : void
      {
         var closeBtn:SimpleButton = null;
         var okBtn:SimpleButton = null;
         if(!searchPanel)
         {
            searchPanel = AssetsManager.getMovieClip("ui_findTeamAlarm");
            closeBtn = searchPanel["closeBtn"];
            okBtn = searchPanel["okBtn"];
            closeBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               DisplayUtil.removeForParent(searchPanel);
            });
            okBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               var _loc2_:String = searchPanel["txt"].text;
               if(_loc2_.replace(/" "/g,"") == "")
               {
                  return;
               }
               search(uint(_loc2_));
               DisplayUtil.removeForParent(searchPanel);
            });
         }
         DisplayUtil.align(searchPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(searchPanel);
      }
      
      private static function search(param1:uint) : void
      {
         var id:uint = param1;
         if(id <= 50000)
         {
            Alarm.show("战队不存在");
            return;
         }
         if(!SocketConnection.hasCmdListener(CommandID.TEAM_GET_INFO))
         {
            SocketConnection.addCmdListener(CommandID.TEAM_GET_INFO,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,arguments.callee);
               var _loc3_:SimpleTeamInfo = param1.data as SimpleTeamInfo;
               show(_loc3_.teamID);
            });
         }
         SocketConnection.send(CommandID.TEAM_GET_INFO,id);
      }
      
      public static function create() : void
      {
         if(MainManager.actorInfo.teamInfo.id != 0)
         {
            Alarm.show("你已经加入了一个战队，如果想要创建一个战队的话，要先退出之前的战队哦！");
            return;
         }
         if(panel == null)
         {
            panel = ModuleManager.getModule(ClientConfig.getAppModule("TeamCreater"),"正在打开创建程序");
            panel.setup();
         }
         panel.show();
      }
      
      public static function join(param1:uint) : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_ADD,onTeamAdd);
         SocketConnection.send(CommandID.TEAM_ADD,param1);
      }
      
      private static function onTeamAdd(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_ADD,onTeamAdd);
         var _loc2_:TeamAddInfo = param1.data as TeamAddInfo;
         if(_loc2_.ret == 0)
         {
            Alarm.show("恭喜你加入战队成功");
            MainManager.actorInfo.teamInfo.id = _loc2_.teamID;
            MainManager.actorInfo.teamInfo.priv = 5;
         }
         else if(_loc2_.ret == 1)
         {
            Alarm.show("你的申请已经提交，等待对方验证");
         }
         else
         {
            Alarm.show("对不起，该战队不允许任何人加入");
         }
      }
      
      public static function enter(param1:uint) : void
      {
         if(param1 == 0)
         {
            Alarm.show("你还没有加入一个战队哦！");
            return;
         }
         MapManager.changeMap(param1,0,MapType.CAMP);
      }
      
      public static function changePriv(param1:uint, param2:uint) : void
      {
         var uid:uint = param1;
         var priv:uint = param2;
         SocketConnection.removeCmdListener(CommandID.TEAM_DELET_MEMBER,arguments.callee);
         SocketConnection.addCmdListener(CommandID.TEAM_CHANGE_ADMIN,function(param1:SocketEvent):void
         {
            Alarm.show("调整成功");
            SocketConnection.removeCmdListener(CommandID.TEAM_CHANGE_ADMIN,arguments.callee);
         });
         SocketConnection.send(CommandID.TEAM_CHANGE_ADMIN,uid,priv);
      }
      
      public static function del(param1:uint) : void
      {
         var uid:uint = param1;
         SocketConnection.removeCmdListener(CommandID.TEAM_DELET_MEMBER,arguments.callee);
         SocketConnection.addCmdListener(CommandID.TEAM_DELET_MEMBER,function(param1:SocketEvent):void
         {
            Alarm.show("删除成功");
            SocketConnection.removeCmdListener(CommandID.TEAM_DELET_MEMBER,arguments.callee);
         });
         SocketConnection.send(CommandID.TEAM_DELET_MEMBER,uid);
      }
      
      public static function invite(param1:uint) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_INVITE_TO_JOIN,onInvite);
         SocketConnection.addCmdListener(CommandID.TEAM_INVITE_TO_JOIN,onInvite);
         SocketConnection.send(CommandID.TEAM_INVITE_TO_JOIN,param1);
      }
      
      private static function onInvite(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_INVITE_TO_JOIN,onInvite);
         Alarm.show("你的邀请已经发出，请耐心等待对方答复");
      }
   }
}

