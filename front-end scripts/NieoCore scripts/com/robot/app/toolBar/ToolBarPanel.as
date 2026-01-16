package com.robot.app.toolBar
{
   import com.robot.app.action.*;
   import com.robot.app.bag.*;
   import com.robot.app.chat.*;
   import com.robot.app.emotion.*;
   import com.robot.app.im.*;
   import com.robot.app.petbag.*;
   import com.robot.app.protectSys.*;
   import com.robot.app.quickWord.*;
   import com.robot.app.specialIcon.*;
   import com.robot.app.team.*;
   import com.robot.app.worldMap.*;
   import com.robot.core.*;
   import com.robot.core.aimat.*;
   import com.robot.core.config.*;
   import com.robot.core.event.*;
   import com.robot.core.info.*;
   import com.robot.core.info.team.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.*;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.SharedObject;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import org.taomee.effect.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class ToolBarPanel extends Sprite
   {
      
      private var _chatPanel:ChatPanel;
      
      public var OLDY:Number;
      
      private var _mainUI:Sprite;
      
      private var _inputTxt:TextField;
      
      private var _inputBtn:SimpleButton;
      
      private var _mapBtn:SimpleButton;
      
      private var _petBtn:SimpleButton;
      
      private var _teamBtn:MovieClip;
      
      private var _showChatBtn:SimpleButton;
      
      private var _nonoBtn:MovieClip;
      
      private var _nonoIcon:MovieClip;
      
      private var _quickWordBtn:SimpleButton;
      
      private var _emotionBtn:SimpleButton;
      
      private var _danceBtn:SimpleButton;
      
      private var _aimatBtn:SimpleButton;
      
      private var _imBtn:MovieClip;
      
      private var _bagBtn:SimpleButton;
      
      private var _addFriendBtn:MovieClip;
      
      private var _addTeamBtn:MovieClip;
      
      private var _homeBtn:SimpleButton;
      
      private var spt_btn:SimpleButton;
      
      private var _soundController_mc:MovieClip;
      
      private var _user_mc:MovieClip;
      
      private var date:Date;
      
      private var _isSend:Boolean = true;
      
      public var panelIsShow:Boolean = true;
      
      public function ToolBarPanel()
      {
         super();
         this._mainUI = UIManager.getSprite("ToolBarMC");
         this._inputTxt = this._mainUI["inputTxt"];
         this._inputBtn = this._mainUI["inputBtn"];
         this._mapBtn = this._mainUI["mapBtn"];
         this._quickWordBtn = this._mainUI["quickWordBtn"];
         this._emotionBtn = this._mainUI["emotionBtn"];
         this._danceBtn = this._mainUI["danceBtn"];
         this._aimatBtn = this._mainUI["aimatBtn"];
         this._imBtn = this._mainUI["imBtn"];
         this._imBtn.gotoAndStop(1);
         this._imBtn.buttonMode = true;
         this._bagBtn = this._mainUI["bagBtn"];
         this._petBtn = this._mainUI["petBtn"];
         this._showChatBtn = this._mainUI["showChatBtn"];
         this._homeBtn = this._mainUI["homeBtn"];
         this._teamBtn = this._mainUI["teamBtn"];
         this._teamBtn.gotoAndStop(1);
         this._nonoBtn = TaskIconManager.getIcon("nonoBtn") as MovieClip;
         this._nonoBtn["nonoNewMC"].mouseEnabled = false;
         this._nonoBtn["nonoNewMC"].mouseChildren = false;
         this._nonoIcon = this._nonoBtn["nonoIcon"];
         this._nonoIcon.buttonMode = true;
         this._nonoIcon.gotoAndStop(1);
         this._nonoIcon["tooltip_mc"].gotoAndStop(1);
         this._nonoIcon["tooltip_mc"].visible = false;
         this._nonoIcon.addEventListener(MouseEvent.ROLL_OVER,this.onRollOverHandler);
         this._nonoIcon.addEventListener(MouseEvent.ROLL_OUT,this.onRollOutHandler);
         this._nonoBtn.x = 862;
         this._nonoBtn.y = -80;
         var _loc1_:uint = uint(SOManager.getUserSO("superNono").data["version"]);
         if(_loc1_ >= ClientConfig.superNoNo)
         {
            DisplayUtil.removeForParent(this._nonoBtn["nonoNewMC"]);
         }
         this._mainUI.addChild(this._nonoBtn);
         this._soundController_mc = this._mainUI["soundController_mc"];
         this._soundController_mc.useHandCursor = true;
         this._soundController_mc.buttonMode = true;
         this._soundController_mc.gotoAndStop(1);
         this._user_mc = this._mainUI["userMc"];
         this._user_mc.useHandCursor = true;
         this._user_mc.buttonMode = true;
         this._user_mc.gotoAndStop(1);
         ProtectSystem.start(this._mainUI["BatteryMC"]);
         addChild(this._mainUI);
         this._inputTxt.restrict = "^妈";
         this._inputTxt.maxChars = 30;
         this._mainUI.mouseEnabled = false;
         mouseEnabled = false;
         this._addFriendBtn = this._mainUI["addFriednBtn"];
         this._addFriendBtn.gotoAndStop(1);
         this._addFriendBtn.visible = false;
         this._addTeamBtn = this._mainUI["addTeamBtn"];
         this._addTeamBtn.gotoAndStop(1);
         this._addTeamBtn.visible = false;
         this._chatPanel = new ChatPanel();
         QuickWordController.setup();
      }
      
      public function showOrHideUser(param1:Boolean) : void
      {
         if(param1)
         {
            if(!UserManager.isShow)
            {
               UserManager.isShow = true;
               MapManager.currentMap.showAllUser();
               this._user_mc.gotoAndStop(1);
               ToolTipManager.add(this._user_mc,"隐藏其他用户");
            }
         }
         else if(UserManager.isShow)
         {
            UserManager.isShow = false;
            MapManager.currentMap.hideAllUser();
            this._user_mc.gotoAndStop(2);
            ToolTipManager.add(this._user_mc,"显示其他用户");
         }
      }
      
      public function closePetBag(param1:Boolean) : void
      {
         this._petBtn.mouseEnabled = param1;
      }
      
      private function getTime() : void
      {
         if(Boolean(this.date))
         {
            this.showTip(this.date);
            return;
         }
         SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,this.onTimeHandler);
         SocketConnection.send(CommandID.SYSTEM_TIME);
      }
      
      private function onTimeHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,this.onTimeHandler);
         var _loc2_:SystemTimeInfo = param1.data as SystemTimeInfo;
         this.date = _loc2_.date;
         this.showTip(this.date);
      }
      
      private function showTip(param1:Date) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = "";
         if(MainManager.actorInfo.superNono)
         {
            if(Boolean(MainManager.actorInfo.autoCharge))
            {
               _loc3_ = "超能等级<font size=\'14\' color=\'#ffff00\'><b>" + MainManager.actorInfo.vipLevel + "</b></font>级\n超级能量满满！";
               this._nonoIcon.gotoAndStop(2);
            }
            else
            {
               _loc2_ = int((MainManager.actorInfo.vipEndTime - param1.time / 1000) / 86400);
               if(_loc2_ < 0)
               {
                  _loc2_ = 0;
               }
               if(MainManager.actorInfo.vipEndTime < param1.time / 1000)
               {
                  _loc3_ = "超能等级<font size=\'14\' color=\'#ffff00\'><b>" + MainManager.actorInfo.vipLevel + "</b></font>级\n超级能量剩余<font color=\'#ffff00\'>" + 0 + "</font>天,快点充能吧！";
                  this._nonoIcon.gotoAndStop(3);
               }
               if(_loc2_ > 5)
               {
                  _loc3_ = "超能等级<font size=\'14\' color=\'#ffff00\'><b>" + MainManager.actorInfo.vipLevel + "</b></font>级\n超级能量剩余<font color=\'#ffff00\'>" + _loc2_ + "</font>天";
                  this._nonoIcon.gotoAndStop(2);
               }
               else if(_loc2_ <= 5 && _loc2_ >= 0)
               {
                  _loc3_ = "超能等级<font size=\'14\' color=\'#ffff00\'><b>" + MainManager.actorInfo.vipLevel + "</b></font>级\n超级能量剩余<font color=\'#ffff00\'>" + _loc2_ + "</font>天,快点充能吧！";
                  this._nonoIcon.gotoAndStop(3);
               }
            }
         }
         else if(MainManager.actorInfo.vip == 2)
         {
            _loc3_ = "曾经超能等级<font size=\'14\' color=\'#ffff00\'><b>" + MainManager.actorInfo.vipLevel + "</b></font>级\nNoNo已经失去超能力,快点充能吧！";
            this._nonoIcon.gotoAndStop(3);
         }
         else if(MainManager.actorInfo.vip == 0)
         {
            _loc3_ = "超能NoNo拥有无与伦比的超能力，快为你的NoNo充能吧！";
            this._nonoIcon.gotoAndStop(1);
         }
         else
         {
            _loc3_ = "快去<font color=\'#ffff00\'>发明室</font>为你的NoNo进行超能融合，开始超能之旅";
            this._nonoIcon.gotoAndStop(2);
         }
         (this._nonoIcon["tooltip_mc"]["mc"]["txt"] as TextField).htmlText = _loc3_;
      }
      
      private function onRollOverHandler(param1:MouseEvent) : void
      {
         this._nonoIcon["tooltip_mc"].visible = true;
         this._nonoIcon["tooltip_mc"].gotoAndPlay(2);
         this.getTime();
      }
      
      private function onRollOutHandler(param1:MouseEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,this.onTimeHandler);
         this._nonoIcon["tooltip_mc"].visible = false;
         (this._nonoIcon["tooltip_mc"]["mc"]["txt"] as TextField).htmlText = "";
         this._nonoIcon["tooltip_mc"].gotoAndStop(1);
         this._nonoIcon.gotoAndStop(1);
      }
      
      private function onMusicMcClickHandler(param1:MouseEvent) : void
      {
         if(SoundManager.getIsPlay == true)
         {
            this._soundController_mc.gotoAndStop(2);
            ToolTipManager.remove(this._soundController_mc);
            ToolTipManager.add(this._soundController_mc,"声音");
            SoundManager.setIsPlay = false;
            SoundManager.stopSound();
         }
         else
         {
            this._soundController_mc.gotoAndStop(1);
            ToolTipManager.remove(this._soundController_mc);
            ToolTipManager.add(this._soundController_mc,"静音");
            SoundManager.setIsPlay = true;
            SoundManager.playSound();
         }
      }
      
      private function onUserMcClickHandler(param1:MouseEvent) : void
      {
         if(UserManager.isShow)
         {
            UserManager.isShow = false;
            MapManager.currentMap.hideAllUser();
            this._user_mc.gotoAndStop(2);
            ToolTipManager.add(this._user_mc,"显示其他用户");
            this.panelIsShow = false;
         }
         else
         {
            UserManager.isShow = true;
            MapManager.currentMap.showAllUser();
            this._user_mc.gotoAndStop(1);
            ToolTipManager.add(this._user_mc,"隐藏其他用户");
            this.panelIsShow = true;
         }
      }
      
      public function show() : void
      {
         this.addEvent();
         DisplayUtil.align(this,null,AlignType.BOTTOM_CENTER);
         this.x = 11;
         LevelManager.toolsLevel.addChild(this);
         this.OLDY = this.y;
      }
      
      public function hide() : void
      {
         this.removeEvent();
         DisplayUtil.removeForParent(this,false);
      }
      
      public function addEvent() : void
      {
         this._inputTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyBoardInput);
         this._inputBtn.addEventListener(MouseEvent.CLICK,this.onInput);
         this._mapBtn.addEventListener(MouseEvent.CLICK,this.onMap);
         this._quickWordBtn.addEventListener(MouseEvent.CLICK,this.onQuickWord);
         this._emotionBtn.addEventListener(MouseEvent.CLICK,this.onEmotion);
         this._danceBtn.addEventListener(MouseEvent.CLICK,this.onDance);
         this._aimatBtn.addEventListener(MouseEvent.CLICK,this.onAimat);
         this._imBtn.addEventListener(MouseEvent.CLICK,this.onIm);
         this._bagBtn.addEventListener(MouseEvent.CLICK,this.onBag);
         this._petBtn.addEventListener(MouseEvent.CLICK,this.onShowPet);
         this._showChatBtn.addEventListener(MouseEvent.CLICK,this.onShowChat);
         this._chatPanel.addEventListener(Event.CLOSE,this.onChatClose);
         this._homeBtn.addEventListener(MouseEvent.CLICK,this.onGoHome);
         this._teamBtn.addEventListener(MouseEvent.CLICK,this.onTeam);
         this._nonoBtn.addEventListener(MouseEvent.CLICK,this.onNonoList);
         this._soundController_mc.addEventListener(MouseEvent.CLICK,this.onMusicMcClickHandler);
         this._user_mc.addEventListener(MouseEvent.CLICK,this.onUserMcClickHandler);
         MessageManager.addEventListener(RobotEvent.ADD_FRIEND_MSG,this.onAddFriend);
         MessageManager.addEventListener(RobotEvent.ADD_TEAM_MSG,this.onInviteJoinTeam);
         ToolTipManager.add(this._soundController_mc,"声音");
         ToolTipManager.add(this._user_mc,"屏蔽其他玩家");
         ToolTipManager.add(this._mapBtn,"地图");
         ToolTipManager.add(this._quickWordBtn,"快捷语言");
         ToolTipManager.add(this._emotionBtn,"表情");
         ToolTipManager.add(this._danceBtn,"动作");
         ToolTipManager.add(this._aimatBtn,"瞄准");
         ToolTipManager.add(this._bagBtn,"储存箱");
         ToolTipManager.add(this._imBtn,"好友");
         ToolTipManager.add(this._homeBtn,"基地");
         ToolTipManager.add(this._petBtn,"精灵");
         ToolTipManager.add(this._teamBtn,"战队");
      }
      
      public function bubble(param1:String) : void
      {
         var _loc2_:DialogBox = null;
         if(Boolean(this._teamBtn))
         {
            _loc2_ = new DialogBox();
            _loc2_.show("战队成员" + param1 + "为战队建设做出了贡献,获得奖励并被表彰！",this._teamBtn.x + 25,5,this);
         }
      }
      
      public function removeEvent() : void
      {
         this._inputBtn.removeEventListener(MouseEvent.CLICK,this.onInput);
         this._mapBtn.removeEventListener(MouseEvent.CLICK,this.onMap);
         this._quickWordBtn.removeEventListener(MouseEvent.CLICK,this.onQuickWord);
         this._emotionBtn.removeEventListener(MouseEvent.CLICK,this.onEmotion);
         this._danceBtn.removeEventListener(MouseEvent.CLICK,this.onDance);
         this._aimatBtn.removeEventListener(MouseEvent.CLICK,this.onAimat);
         this._imBtn.removeEventListener(MouseEvent.CLICK,this.onIm);
         this._bagBtn.removeEventListener(MouseEvent.CLICK,this.onBag);
         this._petBtn.removeEventListener(MouseEvent.CLICK,this.onShowPet);
         this._showChatBtn.removeEventListener(MouseEvent.CLICK,this.onShowChat);
         this._chatPanel.removeEventListener(Event.CLOSE,this.onChatClose);
         this._homeBtn.removeEventListener(MouseEvent.CLICK,this.onGoHome);
         this._teamBtn.removeEventListener(MouseEvent.CLICK,this.onTeam);
         this._soundController_mc.removeEventListener(MouseEvent.CLICK,this.onMusicMcClickHandler);
         this._nonoBtn.removeEventListener(MouseEvent.CLICK,this.onNonoList);
         MessageManager.removeEventListener(RobotEvent.ADD_FRIEND_MSG,this.onAddFriend);
         MessageManager.removeEventListener(RobotEvent.ADD_TEAM_MSG,this.onInviteJoinTeam);
         ToolTipManager.remove(this._soundController_mc);
         ToolTipManager.remove(this._mapBtn);
         ToolTipManager.remove(this._quickWordBtn);
         ToolTipManager.remove(this._emotionBtn);
         ToolTipManager.remove(this._danceBtn);
         ToolTipManager.remove(this._aimatBtn);
         ToolTipManager.remove(this._bagBtn);
         ToolTipManager.remove(this._imBtn);
         ToolTipManager.remove(this._homeBtn);
         ToolTipManager.remove(this._petBtn);
      }
      
      private function onKeyBoardInput(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.onInput(null);
         }
      }
      
      private function onInput(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(!this._isSend)
         {
            return;
         }
         this._isSend = false;
         MainManager.actorModel.chatAction(this._inputTxt.text);
         this._inputTxt.text = "";
         setTimeout(function():void
         {
            _isSend = true;
         },1000);
      }
      
      private function onMap(param1:MouseEvent) : void
      {
         WorldMapController.show();
      }
      
      private function onQuickWord(param1:MouseEvent) : void
      {
         QuickWordController.show(param1.currentTarget as DisplayObject);
      }
      
      private function onEmotion(param1:MouseEvent) : void
      {
         EmotionController.show(param1.currentTarget as DisplayObject);
      }
      
      private function onDance(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         ActorActionManager.showMenu(this._danceBtn);
      }
      
      private function onAimat(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         AimatGridPanel.show(_loc2_);
      }
      
      private function onIm(param1:MouseEvent) : void
      {
         IMController.show();
      }
      
      private function onBag(param1:MouseEvent) : void
      {
         BagController.show();
      }
      
      private function onGoHome(param1:MouseEvent) : void
      {
         MapManager.changeMap(MainManager.actorID);
      }
      
      private function onTeam(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.teamInfo.id == 0)
         {
            Alarm.show("您还没有加入战队");
         }
         else
         {
            TeamController.enter(MainManager.actorInfo.teamInfo.id);
         }
      }
      
      private function onShowPet(param1:MouseEvent) : void
      {
         PetBagController.show();
      }
      
      private function onShowChat(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._showChatBtn);
         this._chatPanel.show();
      }
      
      private function onChatClose(param1:Event) : void
      {
         this._mainUI.addChild(this._showChatBtn);
      }
      
      private function onNonoList(param1:MouseEvent) : void
      {
         (this._nonoIcon["tooltip_mc"]["mc"]["txt"] as TextField).htmlText = "";
         this._nonoIcon["tooltip_mc"].gotoAndStop(1);
         var _loc2_:SharedObject = SOManager.getUserSO("superNono");
         _loc2_.data["version"] = ClientConfig.superNoNo;
         DisplayUtil.removeForParent(this._nonoBtn["nonoNewMC"]);
         SpecialIconController.show(param1.currentTarget as DisplayObject);
      }
      
      private function onAddFriend(param1:RobotEvent) : void
      {
         this._imBtn.gotoAndStop(2);
         this._imBtn.addEventListener(MouseEvent.ROLL_OVER,this.showAddFrindPanel);
         this._imBtn.addEventListener(MouseEvent.ROLL_OUT,this.hideAddFrindPanel);
      }
      
      private function showAddFrindPanel(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         this._imBtn.removeEventListener(MouseEvent.ROLL_OVER,this.showAddFrindPanel);
         this._addFriendBtn.buttonMode = true;
         this._addFriendBtn.visible = true;
         var _loc3_:TextField = this._addFriendBtn["txt"];
         _loc3_.mouseEnabled = false;
         if(MessageManager.friendAddInfoMap.length > 1)
         {
            _loc3_.htmlText = "有<font color=\'#ff0000\'>" + MessageManager.friendAddInfoMap.length + "</font>个赛尔添加你为好友";
         }
         else
         {
            _loc2_ = (MessageManager.friendAddInfoMap.getValues()[0] as InformInfo).nick;
            _loc3_.htmlText = "<font color=\'#ff0000\'>" + _loc2_ + "</font>想要添加你为好友";
         }
         this._addFriendBtn.addEventListener(MouseEvent.CLICK,this.showAddFridMsgPanel);
      }
      
      private function hideAddFrindPanel(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         setTimeout(function():void
         {
            _addFriendBtn.visible = false;
         },2000);
         this._imBtn.addEventListener(MouseEvent.ROLL_OVER,this.showAddFrindPanel);
      }
      
      private function showAddFridMsgPanel(param1:MouseEvent) : void
      {
         this._imBtn.removeEventListener(MouseEvent.ROLL_OVER,this.showAddFrindPanel);
         this._imBtn.removeEventListener(MouseEvent.ROLL_OUT,this.hideAddFrindPanel);
         this._addFriendBtn.visible = false;
         this._addFriendBtn.removeEventListener(MouseEvent.CLICK,this.showAddFridMsgPanel);
         this._imBtn.gotoAndStop(1);
         AddFriendMsgController.showAddFridPanel();
      }
      
      private function onAnswerFriend(param1:RobotEvent) : void
      {
         var txt:TextField = null;
         var evt:RobotEvent = param1;
         txt = null;
         this._imBtn.gotoAndStop(2);
         txt = this._addFriendBtn["txt"];
         txt.mouseEnabled = false;
         this._imBtn.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
         {
            var arr:Array = null;
            var count:uint = 0;
            var timer:Timer = null;
            var evt:MouseEvent = param1;
            arr = null;
            count = 0;
            timer = null;
            var show:Function = function(param1:InformInfo):void
            {
               var _loc2_:String = param1.nick;
               if(param1.accept == 1)
               {
                  txt.htmlText = "成功添加<font color=\'#ff0000\'>" + _loc2_ + "</font>为好友";
               }
               else
               {
                  txt.htmlText = "<font color=\'#ff0000\'>" + _loc2_ + "</font>拒绝成为你的好友";
               }
            };
            _imBtn.removeEventListener(MouseEvent.ROLL_OVER,arguments.callee);
            _addFriendBtn.visible = true;
            _addFriendBtn.mouseEnabled = false;
            _addFriendBtn.buttonMode = false;
            _addFriendBtn.mouseChildren = false;
            arr = MessageManager.friendAnswerInfoMap.getValues();
            count = 0;
            timer = new Timer(2000,arr.length);
            timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               show(arr[count]);
               MessageManager.friendAnswerInfoMap.remove(arr[count].userID);
               if(count == arr.length)
               {
                  timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
                  _addFriendBtn.visible = false;
               }
               ++count;
            });
         });
      }
      
      private function onRemoveFriend(param1:RobotEvent) : void
      {
         var txt:TextField = null;
         var evt:RobotEvent = param1;
         txt = null;
         this._imBtn.gotoAndStop(2);
         txt = this._addFriendBtn["txt"];
         txt.mouseEnabled = false;
         this._imBtn.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
         {
            var arr:Array = null;
            var count:uint = 0;
            var timer:Timer = null;
            var evt:MouseEvent = param1;
            arr = null;
            count = 0;
            timer = null;
            var show:Function = function(param1:InformInfo):void
            {
               var _loc2_:String = param1.nick;
               txt.htmlText = "<font color=\'#ff0000\'>" + _loc2_ + "</font>从好友中删除了你";
            };
            _imBtn.removeEventListener(MouseEvent.ROLL_OVER,arguments.callee);
            _addFriendBtn.visible = true;
            _addFriendBtn.mouseEnabled = false;
            _addFriendBtn.buttonMode = false;
            _addFriendBtn.mouseChildren = false;
            arr = MessageManager.friendRemoveInfoMap.getValues();
            count = 0;
            timer = new Timer(2000,arr.length);
            timer.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               show(arr[count]);
               MessageManager.friendRemoveInfoMap.remove(arr[count].userID);
               ++count;
               if(count == arr.length)
               {
                  timer.removeEventListener(TimerEvent.TIMER,arguments.callee);
                  _addFriendBtn.visible = false;
               }
            });
         });
      }
      
      private function onInviteJoinTeam(param1:RobotEvent) : void
      {
         this._teamBtn.gotoAndStop(2);
         this._teamBtn.addEventListener(MouseEvent.ROLL_OVER,this.showJoinTeamPanel);
         this._teamBtn.addEventListener(MouseEvent.ROLL_OUT,this.hideJoinTeamPanel);
      }
      
      private function showJoinTeamPanel(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         this._teamBtn.removeEventListener(MouseEvent.ROLL_OVER,this.showJoinTeamPanel);
         this._addTeamBtn.buttonMode = true;
         this._addTeamBtn.visible = true;
         var _loc3_:TextField = this._addTeamBtn["txt"];
         _loc3_.mouseEnabled = false;
         if(MessageManager.inviteJoinTeamMap.length > 1)
         {
            _loc3_.htmlText = "有<font color=\'#ff0000\'>" + MessageManager.inviteJoinTeamMap.length + "</font>个赛尔邀请你加入战队";
         }
         else
         {
            _loc2_ = (MessageManager.inviteJoinTeamMap.getValues()[0] as TeamInformInfo).nick;
            _loc3_.htmlText = "<font color=\'#ff0000\'>" + _loc2_ + "</font>邀请你加入战队";
         }
         this._addTeamBtn.addEventListener(MouseEvent.CLICK,this.showAddTeamMsgPanel);
      }
      
      private function hideJoinTeamPanel(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         setTimeout(function():void
         {
            _addTeamBtn.visible = false;
         },2000);
         this._teamBtn.addEventListener(MouseEvent.ROLL_OVER,this.showJoinTeamPanel);
      }
      
      private function showAddTeamMsgPanel(param1:MouseEvent) : void
      {
         this._teamBtn.removeEventListener(MouseEvent.ROLL_OVER,this.showJoinTeamPanel);
         this._teamBtn.removeEventListener(MouseEvent.ROLL_OUT,this.hideJoinTeamPanel);
         this._addTeamBtn.visible = false;
         this._addTeamBtn.removeEventListener(MouseEvent.CLICK,this.showAddTeamMsgPanel);
         this._teamBtn.gotoAndStop(1);
         AddFriendMsgController.showInviteTeamPanel();
      }
      
      public function aimatOff() : void
      {
         this._aimatBtn.mouseEnabled = false;
         this._aimatBtn.filters = [ColorFilter.setGrayscale()];
      }
      
      public function bagOff() : void
      {
         this._bagBtn.mouseEnabled = false;
         this._bagBtn.filters = [ColorFilter.setGrayscale()];
      }
      
      public function homeOff() : void
      {
         this._homeBtn.mouseEnabled = false;
         this._homeBtn.filters = [ColorFilter.setGrayscale()];
      }
      
      public function aimatOn() : void
      {
         this._aimatBtn.mouseEnabled = true;
         this._aimatBtn.filters = [];
      }
      
      public function bagOn() : void
      {
         this._bagBtn.mouseEnabled = true;
         this._bagBtn.filters = [];
      }
      
      public function homeOn() : void
      {
         this._homeBtn.mouseEnabled = true;
         this._homeBtn.filters = [];
      }
      
      public function closeMap() : void
      {
         this._mapBtn.mouseEnabled = false;
      }
      
      public function openMap() : void
      {
         this._mapBtn.mouseEnabled = true;
      }
   }
}

