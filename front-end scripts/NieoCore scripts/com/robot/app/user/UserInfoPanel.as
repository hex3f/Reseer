package com.robot.app.user
{
   import com.robot.app.bag.BagClothPreview;
   import com.robot.app.complain.ComplainManager;
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.im.talk.TalkPanelManager;
   import com.robot.app.popup.FollowPanel;
   import com.robot.app.teacher.TeacherSysManager;
   import com.robot.app.team.TeamController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RelationEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.relation.OnLineInfo;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.RelationManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.manager.UserInfoManager;
   import com.robot.core.skeleton.ClothPreview;
   import com.robot.core.teamInstallation.TeamInfoManager;
   import com.robot.core.teamInstallation.TeamLogo;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.uic.UIPanel;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class UserInfoPanel extends UIPanel
   {
      
      private var _info:UserInfo;
      
      private var _addBtn:SimpleButton;
      
      private var _delBtn:SimpleButton;
      
      private var _fightBtn:SimpleButton;
      
      private var _blackBtn:SimpleButton;
      
      private var _talkBtn:SimpleButton;
      
      private var _homeBtn:SimpleButton;
      
      private var _findBtn:SimpleButton;
      
      private var _complainBtn:SimpleButton;
      
      private var _infoBtn:SimpleButton;
      
      private var _inviteJoinTeamBtn:SimpleButton;
      
      private var _txt:TextField;
      
      private var _showMc:Sprite;
      
      private var teacherIcon:MovieClip;
      
      private var logo:Sprite;
      
      private var clothPrev:BagClothPreview;
      
      private var clothLight:MovieClip;
      
      private var qqMC:Sprite;
      
      public function UserInfoPanel()
      {
         super(UIManager.getSprite("UserPanelMC"));
         this._addBtn = _mainUI["addBtn"];
         this._delBtn = _mainUI["delBtn"];
         this._fightBtn = _mainUI["fightBtn"];
         this._blackBtn = _mainUI["blackBtn"];
         this._talkBtn = new SimpleButton();
         this._homeBtn = _mainUI["homeBtn"];
         this._findBtn = _mainUI["findBtn"];
         this._complainBtn = _mainUI["complainBtn"];
         this._infoBtn = _mainUI["info_btn"];
         this._inviteJoinTeamBtn = _mainUI["inviteJoinTeamBtn"];
         this._txt = _mainUI["txt"];
         this.teacherIcon = UIManager.getMovieClip("Teacher_Icon");
         this.teacherIcon.buttonMode = true;
         this.teacherIcon.x = 30;
         this.teacherIcon.y = 260;
         this._txt.mouseEnabled = false;
         this._addBtn.visible = false;
         this._delBtn.visible = false;
         this._showMc = UIManager.getSprite("ComposeMC");
         this._showMc.mouseEnabled = false;
         this._showMc.mouseChildren = false;
         this._showMc.scaleX = this._showMc.scaleY = 0.9;
         addChild(this._showMc);
         DisplayUtil.align(this._showMc,new Rectangle(0,0,_mainUI.width,_mainUI.height),AlignType.MIDDLE_CENTER,new Point(0,20));
         this._showMc.x -= 4;
         this._showMc.y -= 7.5;
         this.clothPrev = new BagClothPreview(this._showMc,null,ClothPreview.MODEL_SHOW);
         this.qqMC = new Sprite();
         this.qqMC.scaleX = 3.2;
         this.qqMC.scaleY = 1.6;
         var _loc1_:Rectangle = this._showMc.getRect(this._showMc);
         this.qqMC.x = _loc1_.width / 2 + _loc1_.x;
         this.qqMC.y = _loc1_.height + _loc1_.y;
         this._showMc.addChildAt(this.qqMC,0);
         this.logo = new Sprite();
         this.logo.x = 17;
         this.logo.y = 88;
         this.logo.buttonMode = true;
         this.logo.filters = [new GlowFilter(3355443,1,3,3,2)];
         ToolTipManager.add(this.logo,"进入战队要塞");
      }
      
      public function init(param1:uint) : void
      {
         this.setIsFriend(param1);
         if(param1 == MainManager.actorID)
         {
            this._info = MainManager.actorInfo;
            this.initInfo();
         }
         else
         {
            UserInfoManager.getInfo(param1,this.onInfo);
         }
      }
      
      public function show(param1:uint) : void
      {
         addChild(this.logo);
         _mainUI["nonoMc"].visible = false;
         DisplayUtil.removeAllChild(this.logo);
         _show();
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         this.removeEvent();
         this.init(param1);
      }
      
      override public function hide() : void
      {
         super.hide();
         DisplayUtil.removeAllChild(this.qqMC);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._info = null;
         this._addBtn = null;
         this._delBtn = null;
         this._fightBtn = null;
         this._blackBtn = null;
         this._talkBtn = null;
         this._findBtn = null;
         this._txt = null;
         this.clothPrev = null;
         this._showMc = null;
         this._complainBtn = null;
      }
      
      private function onInfo(param1:UserInfo) : void
      {
         this._info = param1;
         if(AllUserInfoController.getStatus == true)
         {
            AllUserInfoController.show(this._info,LevelManager.appLevel);
         }
         if(this._info.teamID != 0)
         {
            this.getTeamLogo();
         }
         this.initInfo();
      }
      
      private function initInfo() : void
      {
         var _loc1_:* = 0;
         this._txt.text = this._info.nick + "\n(" + this._info.userID + ")";
         if(this._info.vip >= 1)
         {
            _mainUI["nonoMc"].visible = true;
            _mainUI["nonoMc"]["vipStageMC"].gotoAndStop(this._info.vipLevel);
            ToolTipManager.add(_mainUI["nonoMc"],this._info.vipLevel + "级超能NoNo");
         }
         if(this._info.isCanBeTeacher)
         {
            this.teacherIcon.gotoAndStop(1);
            addChild(this.teacherIcon);
            if(this._info.graduationCount >= 5)
            {
               _loc1_ = uint(uint(this._info.graduationCount / 5) + 1);
               if(_loc1_ >= 5)
               {
                  this.teacherIcon.gotoAndStop(6);
               }
               else
               {
                  this.teacherIcon.gotoAndStop(_loc1_);
               }
            }
         }
         else
         {
            DisplayUtil.removeForParent(this.teacherIcon);
         }
         this.addEvent();
         this.clothPrev.changeColor(this._info.color);
         this.clothPrev.showCloths(this._info.clothes);
         this.clothPrev.showDoodle(this._info.texture);
         if(this._info.userID != MainManager.actorInfo.teacherID)
         {
            this.teacherIcon.addEventListener(MouseEvent.CLICK,this.requestBeTeacher);
         }
         if(this._info.userID == MainManager.actorInfo.teacherID)
         {
            ToolTipManager.add(this.teacherIcon,"我的教官");
         }
         else
         {
            ToolTipManager.add(this.teacherIcon,"申请他做我的教官");
         }
         this.showClothLight();
      }
      
      private function showClothLight() : void
      {
         DisplayUtil.removeForParent(this.clothLight);
         var _loc1_:uint = uint(this._info.clothMaxLevel);
         if(_loc1_ > 1)
         {
            ResourceManager.getResource(ClientConfig.getClothLightUrl(_loc1_),this.onLoadLight);
            ResourceManager.getResource(ClientConfig.getClothCircleUrl(_loc1_),this.onLoadQQ);
         }
      }
      
      private function onLoadLight(param1:DisplayObject) : void
      {
         this.clothLight = param1 as MovieClip;
         this.clothLight.scaleX = this.clothLight.scaleY = 3;
         var _loc2_:Rectangle = this._showMc.getRect(this._showMc);
         this.clothLight.x = _loc2_.width / 2 + _loc2_.x;
         this.clothLight.y = _loc2_.height + _loc2_.y;
         this._showMc.addChild(this.clothLight);
      }
      
      private function onLoadQQ(param1:DisplayObject) : void
      {
         DisplayUtil.removeAllChild(this.qqMC);
         this.qqMC.addChild(param1);
      }
      
      private function setIsFriend(param1:uint) : void
      {
         if(RelationManager.isFriend(param1))
         {
            this._findBtn.mouseEnabled = true;
            this._findBtn.alpha = 1;
            this._delBtn.visible = true;
            this._delBtn.addEventListener(MouseEvent.CLICK,this.onDel);
            this._addBtn.visible = false;
            this._addBtn.removeEventListener(MouseEvent.CLICK,this.onAdd);
         }
         else
         {
            this._findBtn.mouseEnabled = false;
            this._findBtn.alpha = 0.5;
            this._addBtn.visible = true;
            this._addBtn.addEventListener(MouseEvent.CLICK,this.onAdd);
            this._delBtn.visible = false;
            this._delBtn.removeEventListener(MouseEvent.CLICK,this.onDel);
         }
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         this._fightBtn.addEventListener(MouseEvent.CLICK,this.onFight);
         this._blackBtn.addEventListener(MouseEvent.CLICK,this.onBlack);
         this._talkBtn.addEventListener(MouseEvent.CLICK,this.onTalk);
         this._homeBtn.addEventListener(MouseEvent.CLICK,this.onHome);
         this._findBtn.addEventListener(MouseEvent.CLICK,this.onFind);
         this._infoBtn.addEventListener(MouseEvent.CLICK,this.onInfoBtnClickHandler);
         this._inviteJoinTeamBtn.addEventListener(MouseEvent.CLICK,this.onInviteJoinTeam);
         this._complainBtn.addEventListener(MouseEvent.CLICK,this.complainUser);
         RelationManager.addEventListener(RelationEvent.FRIEND_ADD,this.onRelation);
         RelationManager.addEventListener(RelationEvent.FRIEND_REMOVE,this.onRelation);
         ToolTipManager.add(this._addBtn,"加为好友");
         ToolTipManager.add(this._delBtn,"删除好友");
         ToolTipManager.add(this._fightBtn,"发起对战");
         ToolTipManager.add(this._homeBtn,"基地访问");
         ToolTipManager.add(this._blackBtn,"加入黑名单");
         ToolTipManager.add(this._findBtn,"查找好友位置");
         ToolTipManager.add(this._infoBtn,"详细信息");
         ToolTipManager.add(this._inviteJoinTeamBtn,"邀请他加入战队");
         ToolTipManager.add(this._complainBtn,"举报该用户");
      }
      
      private function onInfoBtnClickHandler(param1:MouseEvent) : void
      {
         AllUserInfoController.show(this._info,this);
      }
      
      private function onInviteJoinTeam(param1:MouseEvent) : void
      {
         TeamController.invite(this._info.userID);
         this.hide();
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         if(AllUserInfoController.getStatus == true)
         {
            AllUserInfoController.hide();
         }
         this._addBtn.removeEventListener(MouseEvent.CLICK,this.onAdd);
         this._delBtn.removeEventListener(MouseEvent.CLICK,this.onDel);
         this._fightBtn.removeEventListener(MouseEvent.CLICK,this.onFight);
         this._blackBtn.removeEventListener(MouseEvent.CLICK,this.onBlack);
         this._talkBtn.removeEventListener(MouseEvent.CLICK,this.onTalk);
         this._homeBtn.removeEventListener(MouseEvent.CLICK,this.onHome);
         this._findBtn.removeEventListener(MouseEvent.CLICK,this.onFind);
         this._infoBtn.removeEventListener(MouseEvent.CLICK,this.onInfoBtnClickHandler);
         this._infoBtn.removeEventListener(MouseEvent.CLICK,this.onInviteJoinTeam);
         this._complainBtn.removeEventListener(MouseEvent.CLICK,this.complainUser);
         RelationManager.removeEventListener(RelationEvent.FRIEND_ADD,this.onRelation);
         RelationManager.removeEventListener(RelationEvent.FRIEND_REMOVE,this.onRelation);
         this.teacherIcon.removeEventListener(MouseEvent.CLICK,this.requestBeTeacher);
         if(_mainUI["nonoMc"].visible == true)
         {
            ToolTipManager.remove(_mainUI["nonoMc"]);
         }
         ToolTipManager.remove(this._addBtn);
         ToolTipManager.remove(this._delBtn);
         ToolTipManager.remove(this._fightBtn);
         ToolTipManager.remove(this._homeBtn);
         ToolTipManager.remove(this._blackBtn);
         ToolTipManager.remove(this.teacherIcon);
         ToolTipManager.remove(this._infoBtn);
      }
      
      private function onAdd(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.hide();
         Alert.show("你想和" + this._info.nick + "(" + this._info.userID + ")\r成为好友吗?",function():void
         {
            RelationManager.addFriend(_info.userID);
         });
      }
      
      private function onDel(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.hide();
         Alert.show("你要删除好友" + this._info.nick + "(" + this._info.userID + ")吗?",function():void
         {
            RelationManager.removeFriend(_info.userID);
         });
      }
      
      private function onFight(param1:MouseEvent) : void
      {
         this.hide();
         FightInviteManager.fightWithPlayer(this._info);
      }
      
      private function onBlack(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         Alert.show("你确定要把" + this._info.nick + "(" + this._info.userID + ")加入黑名单吗?",function():void
         {
            RelationManager.addBlack(_info.userID);
         });
      }
      
      private function onTalk(param1:MouseEvent) : void
      {
         TalkPanelManager.showTalkPanel(this._info.userID);
      }
      
      private function onHome(param1:MouseEvent) : void
      {
         MapManager.changeMap(this._info.userID);
      }
      
      private function onFind(param1:MouseEvent) : void
      {
         UserInfoManager.seeOnLine([this._info.userID],this.checkOnlineHandler);
      }
      
      private function checkOnlineHandler(param1:Array) : void
      {
         var _loc2_:OnLineInfo = null;
         var _loc3_:OnLineInfo = null;
         if(param1.length > 0)
         {
            for each(_loc3_ in param1)
            {
               if(_loc3_.userID == this._info.userID)
               {
                  _loc2_ = _loc3_;
                  break;
               }
            }
            this._info.serverID = _loc2_.serverID;
            this._info.mapID = _loc2_.mapID;
            if(this._info.mapID > MapManager.ID_MAX)
            {
               Alarm.show("你的好友" + this._info.nick + "(" + this._info.userID + ")\n在<font color=\'#FF0000\'>基地</font>里");
               return;
            }
            if(_loc2_.serverID != MainManager.serverID)
            {
               Alarm.show("你的好友" + this._info.nick + "(" + this._info.userID + ")在" + TextFormatUtil.getRedTxt(_loc2_.serverID + "号") + "服务器");
               return;
            }
            if(this._info.mapID == MainManager.actorInfo.mapID)
            {
               Alarm.show("你的好友" + this._info.nick + "(" + this._info.userID + ")\n就在您的身边哦");
               return;
            }
            FollowPanel.show(this._info);
            return;
         }
         Alarm.show("你的好友" + this._info.nick + "(" + this._info.userID + ")\n现在不在线哦");
      }
      
      private function onRelation(param1:RelationEvent) : void
      {
         this.setIsFriend(param1.userID);
      }
      
      private function requestBeTeacher(param1:MouseEvent) : void
      {
         this.hide();
         if(this._info.userID == MainManager.actorID)
         {
            Alarm.show("你不能申请自己做教官");
            return;
         }
         if(MainManager.actorInfo.teacherID == 0)
         {
            TeacherSysManager.addTeacher(this._info.userID);
         }
         else
         {
            Alarm.show("你已经有一个教官了，要珍惜哦！");
         }
      }
      
      private function complainUser(param1:MouseEvent) : void
      {
         ComplainManager.show(this._info);
      }
      
      private function getTeamLogo() : void
      {
         TeamInfoManager.getSimpleTeamInfo(this._info.teamInfo.id,this.onGetInfo);
      }
      
      private function onGetInfo(param1:SimpleTeamInfo) : void
      {
         var _loc2_:TeamLogo = new TeamLogo();
         _loc2_.info = param1;
         _loc2_.scaleX = _loc2_.scaleY = 0.8;
         this.logo.addChild(_loc2_);
         _loc2_.addEventListener(MouseEvent.CLICK,this.showTeamInfo);
      }
      
      private function showTeamInfo(param1:MouseEvent) : void
      {
         var _loc2_:TeamLogo = param1.currentTarget as TeamLogo;
         TeamController.enter(_loc2_.teamID);
      }
   }
}

