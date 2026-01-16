package com.robot.app.cmd
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.CommandID;
   import com.robot.core.cmd.VipCmdListener;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.AlertInfo;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.info.SystemMsgInfo;
   import com.robot.core.info.SystemTimeInfo;
   import com.robot.core.manager.*;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.SharedObject;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class SysMsgCmdListener
   {
      
      private static var owner:SysMsgCmdListener;
      
      public static var npcLink:Array = [""];
      
      public static var npcName:Array = ["","船长罗杰","机械师茜茜","博士派特","导航员爱丽丝","站长贾斯汀","诺诺","发明家肖恩","米鲁"];
      
      private static const FIRST_OPEN:uint = 1;
      
      private static const OPEN_AGAIN:uint = 2;
      
      private static const CANCEL:uint = 3;
      
      private static const NONO_UPDATE:uint = 4;
      
      private var panel:MovieClip;
      
      private var npcMC:Sprite;
      
      private var icon:SimpleButton;
      
      private var isBeanOver:Boolean = false;
      
      private var msgArray:Array = [];
      
      private var newYearPanel:MovieClip;
      
      private var morePanel:AppModel;
      
      private var npcArary:Array = ["","主播纽斯","船长罗杰","博士派特","精灵学者迪恩","唔理哇啦","百事通罗开","工程是苏克","叽哩呱啦","机械师茜茜","总教官雷蒙","发明家肖恩","站长贾斯汀","米鲁"];
      
      private var mapArary:Array = ["","传送舱","船长室","实验室","资料室","去瞭望舱","瞭望露台","动力室","瞭望露台","机械室","教官办公室","发明室","精灵太空站"];
      
      public function SysMsgCmdListener()
      {
         super();
      }
      
      public static function getInstance() : SysMsgCmdListener
      {
         if(!owner)
         {
            owner = new SysMsgCmdListener();
         }
         return owner;
      }
      
      public function addInfo(param1:SystemMsgInfo) : void
      {
         this.msgArray.push(param1);
         this.checkLength();
      }
      
      public function start() : void
      {
         npcLink.push(NpcTipDialog.SHIPER);
         npcLink.push(NpcTipDialog.CICI);
         npcLink.push(NpcTipDialog.DOCTOR);
         npcLink.push(NpcTipDialog.IRIS);
         npcLink.push(NpcTipDialog.JUSTIN);
         npcLink.push(NpcTipDialog.NONO);
         npcLink.push(NpcTipDialog.SHAWN);
         npcLink.push(NpcTipDialog.MILU);
         SocketConnection.addCmdListener(CommandID.SYSTEM_MESSAGE,this.onSystemMsg);
         EventManager.addEventListener(RobotEvent.BEAN_COMPLETE,this.onBeanOver);
         EventManager.addEventListener(VipCmdListener.BE_VIP,this.onBeVip);
         EventManager.addEventListener(VipCmdListener.FIRST_VIP,this.onBeVip);
         SocketConnection.addCmdListener(CommandID.VIP_LEVEL_UP,this.onVipLevelUp);
         SocketConnection.addCmdListener(CommandID.ALERT,this.onAlert);
      }
      
      private function onAlert(param1:Object) : void
      {
         var _loc2_:AlertInfo = param1.data as AlertInfo;
         Alarm.show(_loc2_.msg);
      }
      
      private function onVipLevelUp(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:* = _loc2_.readUnsignedInt();
         if(_loc3_ > 4)
         {
            _loc3_ = 4;
         }
      }
      
      private function onBeVip(param1:Event) : void
      {
         this.onOpen(null);
      }
      
      private function onOpen(param1:SocketEvent) : void
      {
         var _loc2_:NonoInfo = null;
         if(Boolean(MainManager.actorModel.nono))
         {
            _loc2_ = MainManager.actorModel.nono.info;
            _loc2_.superNono = true;
            MainManager.actorModel.hideNono();
            MainManager.actorModel.showNono(_loc2_,MainManager.actorInfo.actionType);
         }
         if(Boolean(NonoManager.info))
         {
            NonoManager.info.superNono = true;
            NonoManager.info.power = 100;
            NonoManager.info.mate = 100;
         }
      }
      
      private function onBeanOver(param1:Event) : void
      {
         this.isBeanOver = true;
         this.checkLength();
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,this.onSysTime);
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private function onSysTime(param1:SocketEvent) : void
      {
         var _loc2_:SharedObject = null;
         var _loc3_:SystemMsgInfo = null;
         SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,this.onSysTime);
         var _loc4_:Date = (param1.data as SystemTimeInfo).date;
         if(_loc4_.getDay() == 5 && ClientConfig.uiVersion != SOManager.getUser_Info().data["nonoExp"] && Boolean(MainManager.actorInfo.hasNono))
         {
            _loc2_ = SOManager.getUser_Info();
            _loc2_.data["nonoExp"] = ClientConfig.uiVersion;
            SOManager.flush(_loc2_);
            _loc3_ = new SystemMsgInfo();
            _loc3_.npc = 7;
            _loc3_.msgTime = _loc4_.getTime() / 1000;
            _loc3_.msg = "    你的" + MainManager.actorInfo.nonoNick + "周全照顾使精灵们积累了额外的经验奖励，快去发明室的经验接收器那里领取本周的奖励吧！";
            this.msgArray.push(_loc3_);
            this.checkLength();
         }
      }
      
      private function onSystemMsg(param1:SocketEvent) : void
      {
         var _loc2_:SystemMsgInfo = param1.data as SystemMsgInfo;
         this.msgArray.push(_loc2_);
         if(this.isBeanOver)
         {
            this.checkLength();
         }
      }
      
      private function checkLength() : void
      {
         var _loc1_:VipNotManager = null;
         if(!this.isBeanOver)
         {
            return;
         }
         if(this.msgArray.length == 0)
         {
            this.hideIcon();
            return;
         }
         var _loc2_:SystemMsgInfo = this.msgArray[0];
         if(_loc2_.type == FIRST_OPEN || _loc2_.type == OPEN_AGAIN || _loc2_.type == CANCEL || _loc2_.type == NONO_UPDATE)
         {
            _loc2_ = this.msgArray.shift() as SystemMsgInfo;
            _loc1_ = new VipNotManager();
            if(_loc2_.type == FIRST_OPEN)
            {
               _loc1_.goNow(_loc2_);
            }
            else if(_loc2_.type == OPEN_AGAIN || _loc2_.type == NONO_UPDATE)
            {
               _loc1_.openAgain(_loc2_);
            }
            else if(_loc2_.type == CANCEL)
            {
               _loc1_.cancelHandler(_loc2_);
            }
            this.checkLength();
            return;
         }
         if(this.msgArray.length > 0)
         {
            this.showIcon();
         }
         else if(this.msgArray.length == 0)
         {
            this.hideIcon();
         }
      }
      
      private function showIcon() : void
      {
         if(!this.icon)
         {
            this.icon = UIManager.getButton("System_Msg_Icon");
            this.icon.x = 188;
            this.icon.y = 20;
            this.icon.addEventListener(MouseEvent.CLICK,this.showSysMsg);
         }
         LevelManager.iconLevel.addChild(this.icon);
      }
      
      private function hideIcon() : void
      {
         DisplayUtil.removeForParent(this.icon);
      }
      
      private function showSysMsg(param1:MouseEvent) : void
      {
         var data:SystemMsgInfo = null;
         var event:MouseEvent = param1;
         var date:Date = null;
         var str:String = null;
         if(!this.panel)
         {
            this.panel = this.getPanel();
            this.newYearPanel = this.getNewYearPanel();
         }
         data = this.msgArray.shift() as SystemMsgInfo;
         if(!data.isNewYear)
         {
            this.panel["titleTxt"].text = "亲爱的" + MainManager.actorInfo.nick;
            this.panel["msgTxt"].htmlText = data.msg;
            date = new Date(data.msgTime * 1000);
            str = npcName[data.npc] + "\r";
            this.panel["timeTxt"].text = str + date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate() + "日";
            ResourceManager.getResource(ClientConfig.getNpcSwfPath(npcLink[data.npc]),function(param1:DisplayObject):void
            {
               npcMC.addChild(param1);
            },"npc");
            LevelManager.appLevel.addChild(this.panel);
         }
         else
         {
            this.showNewYearInfo(data);
         }
         this.checkLength();
      }
      
      private function getPanel() : MovieClip
      {
         var _loc1_:MovieClip = UIManager.getMovieClip("ui_SysMsg_Panel");
         var _loc2_:SimpleButton = _loc1_["closeBtn"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.closeHandler);
         this.npcMC = new Sprite();
         this.npcMC.scaleX = this.npcMC.scaleY = 0.65;
         this.npcMC.x = 50;
         this.npcMC.y = 86;
         _loc1_.addChild(this.npcMC);
         DisplayUtil.align(_loc1_,null,AlignType.MIDDLE_CENTER);
         return _loc1_;
      }
      
      private function getNewYearPanel() : MovieClip
      {
         var _loc1_:MovieClip = AssetsManager.getMovieClip("lib_year_note");
         var _loc2_:SimpleButton = _loc1_["closeBtn"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.closeNewYearHandler);
         var _loc3_:MovieClip = _loc1_["moreBtn"];
         var _loc4_:MovieClip = _loc1_["openBtn"];
         _loc3_.buttonMode = _loc4_.buttonMode = true;
         _loc3_.addEventListener(MouseEvent.CLICK,this.onMoreHandler);
         _loc4_.addEventListener(MouseEvent.CLICK,this.onOpenHandler);
         DisplayUtil.align(_loc1_,null,AlignType.MIDDLE_CENTER);
         return _loc1_;
      }
      
      private function onMoreHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.newYearPanel,false);
         if(!this.morePanel)
         {
            this.morePanel = new AppModel(ClientConfig.getAppModule("CongratulatePanel"),"正在打开...");
            this.morePanel.setup();
         }
         this.morePanel.show();
      }
      
      private function onOpenHandler(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         var r:VipSession = new VipSession();
         r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
         {
         });
         r.getSession();
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.panel,false);
         DisplayUtil.removeAllChild(this.npcMC);
      }
      
      private function closeNewYearHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.newYearPanel,false);
      }
      
      private function showNewYearInfo(param1:SystemMsgInfo) : void
      {
         SOManager.getUser_Info().data["isReadMsg"] = ClientConfig.newsVersion;
         this.newYearPanel["txt"].htmlText = param1.msg;
         LevelManager.appLevel.addChild(this.newYearPanel);
      }
   }
}

