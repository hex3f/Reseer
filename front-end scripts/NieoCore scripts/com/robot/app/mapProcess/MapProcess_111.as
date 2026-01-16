package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.panel.FightMatchingPanel;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.book.BookManager;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_111 extends BaseMapProcess
   {
      
      private static const NAME_ARR:Array = ["草","水","火","电","战斗","飞行","机械","地面","冰"];
      
      private var _fightPanel:MovieClip;
      
      private var _fightType:uint = 1;
      
      private var waitPanel:MovieClip;
      
      private var _iconBtn:SimpleButton;
      
      private var _getRewardsBtn:SimpleButton;
      
      private var _fightBtn:SimpleButton;
      
      private var exMc:MovieClip;
      
      private var expanel:AppModel;
      
      private var panelCard:AppModel;
      
      private var _choosePanel:AppModel;
      
      private var timeOutId:uint;
      
      public function MapProcess_111()
      {
         super();
      }
      
      override protected function init() : void
      {
         conLevel["pet"].visible = false;
         this.initPet();
         this._fightPanel = MapLibManager.getMovieClip("ui_pet_king_panel");
         this._iconBtn = btnLevel["bookBtn"];
         this._iconBtn.addEventListener(MouseEvent.CLICK,this.onShowPanel);
         ToolTipManager.add(this._iconBtn,"大师杯兑奖手册");
         this._getRewardsBtn = conLevel["getRewardsBtn"];
         this._getRewardsBtn.addEventListener(MouseEvent.CLICK,this.onShowPanel);
         ToolTipManager.add(this._getRewardsBtn,"大师杯兑奖手册");
         this._fightBtn = conLevel["fightBtn"];
         ToolTipManager.add(this._fightBtn,"精灵大师杯");
         this._fightBtn.addEventListener(MouseEvent.CLICK,this.onFightBtnClick);
      }
      
      private function initPet() : void
      {
         if(TasksManager.getTaskStatus(727) != TasksManager.COMPLETE)
         {
            this.catchPet();
         }
      }
      
      private function catchPet() : void
      {
         if(Boolean(MainManager.actorModel.pet))
         {
            if(MainManager.actorModel.pet.info.petID == 897 || MainManager.actorModel.pet.info.petID == 898)
            {
               this.showPet();
            }
         }
      }
      
      private function showPet() : void
      {
         conLevel["pet"].visible = true;
         conLevel["pet"].buttonMode = true;
         conLevel["pet"].addEventListener(MouseEvent.CLICK,this.onClickPet);
      }
      
      private function onClickPet(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         MainManager.actorModel.walkAction(new Point(650,130),function():void
         {
            FightInviteManager.fightWithBoss("卡塔",0);
         });
      }
      
      private function onClickExchangeHandler(param1:MouseEvent) : void
      {
         if(!this.expanel)
         {
            this.expanel = new AppModel(ClientConfig.getAppModule("YuanDanExchangePanel"),"正在打开");
            this.expanel.setup();
         }
         this.expanel.show();
      }
      
      private function onExchangeCardBtnClick(param1:MouseEvent) : void
      {
         if(!this.panelCard)
         {
            this.panelCard = new AppModel(ClientConfig.getAppModule("ExchangeMasterCards"),"正在打开面板....");
            this.panelCard.setup();
         }
         this.panelCard.show();
      }
      
      private function onFightBtnClick(param1:MouseEvent) : void
      {
         if(!this._choosePanel)
         {
            this._choosePanel = new AppModel(ClientConfig.getAppModule("PetKingChoosePanel"),"加载精灵大师杯面板");
            this._choosePanel.setup();
            this._choosePanel.sharedEvents.addEventListener("hasChooseFight",this.onHasChooseFight);
         }
         this._choosePanel.show();
      }
      
      private function onHasChooseFight(param1:DynamicEvent) : void
      {
         var _loc2_:int = param1.paramObject as int;
         this.showFightPanel(_loc2_);
      }
      
      private function showFightPanel(param1:uint) : void
      {
         var _startFightBtn:SimpleButton = null;
         var _closeBtn:SimpleButton = null;
         var str:String = null;
         var t:uint = param1;
         var mc:MovieClip = this._fightPanel["mc"];
         var txt:TextField = this._fightPanel["txt"];
         mc.gotoAndStop(t);
         txt.mouseWheelEnabled = false;
         txt.mouseEnabled = false;
         _startFightBtn = this._fightPanel["startFightBtn"];
         _startFightBtn.addEventListener(MouseEvent.CLICK,this.onStartFight);
         _closeBtn = this._fightPanel["closeBtn"];
         _closeBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            DisplayUtil.removeForParent(_fightPanel);
         });
         this._fightType = t;
         str = NAME_ARR[t - 1] + "系大师杯需要带上你的" + NAME_ARR[t - 1] + "系精灵才能参加，以1对1的形式进行比赛。";
         txt.htmlText = "    " + str;
         LevelManager.appLevel.addChild(this._fightPanel);
         DisplayUtil.align(this._fightPanel,null,AlignType.MIDDLE_CENTER);
      }
      
      private function onStartFight(param1:MouseEvent) : void
      {
         var _loc2_:* = null;
         DisplayUtil.removeForParent(this._fightPanel);
         var _loc3_:PetInfo = PetManager.getPetInfo(PetManager.defaultTime);
         if(PetManager.length == 0)
         {
            Alarm.show("你没有带赛尔精灵，不能战斗!");
            return;
         }
         if(_loc3_ == null)
         {
            Alarm.show("你没有可出战的精灵！");
            return;
         }
         if(_loc3_.hp == 0)
         {
            Alarm.show("你的首发精灵血量不足！");
            return;
         }
         var _loc4_:String = PetXMLInfo.getTypeCN(_loc3_.id);
         if(NAME_ARR.indexOf(_loc4_) + 1 == this._fightType)
         {
            this.startFight();
         }
         else
         {
            Alarm.show("将你的<font color=\'#ff0000\'>" + NAME_ARR[this._fightType - 1] + "</font>系精灵设为首选，赶快参加到激烈的精灵大师杯中吧！");
         }
      }
      
      private function startFight() : void
      {
         PetFightModel.mode = PetFightModel.SINGLE_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
         SocketConnection.addCmdListener(CommandID.INVITE_FIGHT_CANCEL,this.onCancelHandler);
         EventManager.addEventListener(PetFightEvent.START_FIGHT,this.onPetStartFight);
         SocketConnection.send(CommandID.PET_KING_JOIN,11,this._fightType);
         FightMatchingPanel.show(this.closeKingFight);
         this.timeOutId = setTimeout(function():void
         {
            FightMatchingPanel.hide();
            closeKingFight();
         },30000);
      }
      
      private function closeKingFight() : void
      {
         SocketConnection.send(CommandID.INVITE_FIGHT_CANCEL);
         clearTimeout(this.timeOutId);
      }
      
      private function onPetStartFight(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.START_FIGHT,this.onPetStartFight);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,this.onFightClose);
      }
      
      private function onCancelHandler(param1:SocketEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.START_FIGHT,this.onPetStartFight);
         SocketConnection.removeCmdListener(CommandID.INVITE_FIGHT_CANCEL,this.onCancelHandler);
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.onFightClose);
      }
      
      private function onShowPanel(param1:MouseEvent) : void
      {
         BookManager.show("PetKingRewardsPanel");
      }
      
      private function onFightClose(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,this.onFightClose);
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         if(TasksManager.getTaskStatus(106) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.complete(106,0,null,true);
         }
      }
      
      override public function destroy() : void
      {
         ToolTipManager.remove(this._iconBtn);
         this._iconBtn.removeEventListener(MouseEvent.CLICK,this.onShowPanel);
         ToolTipManager.remove(this._fightBtn);
         ToolTipManager.remove(this._getRewardsBtn);
         ToolTipManager.remove(conLevel["exchangeCard_btn"]);
         this._getRewardsBtn.removeEventListener(MouseEvent.CLICK,this.onShowPanel);
         this._fightBtn.removeEventListener(MouseEvent.CLICK,this.onFightBtnClick);
         conLevel["exchangeCard_btn"].removeEventListener(MouseEvent.CLICK,this.onExchangeCardBtnClick);
         if(Boolean(this.panelCard))
         {
            this.panelCard.destroy();
            this.panelCard = null;
         }
         if(Boolean(this._choosePanel))
         {
            this._choosePanel.sharedEvents.removeEventListener("hasChooseFight",this.onHasChooseFight);
            this._choosePanel.destroy();
            this._choosePanel = null;
         }
         clearTimeout(this.timeOutId);
      }
   }
}

