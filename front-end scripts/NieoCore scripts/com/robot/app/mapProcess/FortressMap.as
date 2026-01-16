package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.*;
   import com.robot.app.storage.*;
   import com.robot.app.toolBar.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.utils.*;
   import gs.*;
   import gs.easing.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class FortressMap extends BaseMapProcess
   {
      
      private var _storageIcon:SimpleButton;
      
      private var _editIcon:SimpleButton;
      
      private var _saveIcon:SimpleButton;
      
      private var _bookIcon:SimpleButton;
      
      private var _reallIcon:SimpleButton;
      
      private var _infoIcon:SimpleButton;
      
      private var _memberIcon:SimpleButton;
      
      private var _isEdieing:Boolean = false;
      
      private var _armShow:ArmShow;
      
      private var _bookPanel:AppModel;
      
      private var _memberPanel:AppModel;
      
      private var _teamContributeMc:MovieClip;
      
      private var _infoPanel:AppModel;
      
      public function FortressMap()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:uint = 0;
         this._armShow = new ArmShow();
         this._infoIcon = UIManager.getButton("UI_Arm_FightInfo_Icon");
         LevelManager.iconLevel.addChild(this._infoIcon);
         DisplayUtil.align(this._infoIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-160));
         ToolTipManager.add(this._infoIcon,"战队资料");
         this._infoIcon.addEventListener(MouseEvent.CLICK,this.onInfo);
         this._memberIcon = UIManager.getButton("UI_Arm_Member_Icon");
         LevelManager.iconLevel.addChild(this._memberIcon);
         DisplayUtil.align(this._memberIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-105));
         ToolTipManager.add(this._memberIcon,"成员列表");
         this._memberIcon.addEventListener(MouseEvent.CLICK,this.onMember);
         if(MainManager.actorInfo.teamInfo.id == MainManager.actorInfo.mapID)
         {
            _loc1_ = uint(MainManager.actorInfo.teamInfo.priv);
            SocketConnection.addCmdListener(CommandID.CONTRIBUTE_CHANGE,this.onChangeHandler);
            if(_loc1_ == 0)
            {
               this.actorRoomInit();
               this.boundsBtn(new Point(-10,60));
            }
            else
            {
               this.boundsBtn(new Point(-10,-50));
            }
         }
      }
      
      private function onChangeHandler(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:Number = _loc2_.readUnsignedInt();
         MainManager.actorInfo.teamInfo.canExContribution += _loc3_;
         MainManager.actorInfo.teamInfo.allContribution += _loc3_;
         if(Boolean(this._teamContributeMc))
         {
            this._teamContributeMc["mc"].visible = true;
            this._teamContributeMc["mc"].gotoAndPlay(1);
            this._teamContributeMc["txt"].text = MainManager.actorInfo.teamInfo.canExContribution.toString();
         }
      }
      
      private function boundsBtn(param1:Point) : void
      {
         this._teamContributeMc = TaskIconManager.getIcon("TeamContributeMc") as MovieClip;
         this._teamContributeMc["mc"].visible = false;
         this._teamContributeMc["mc"].gotoAndStop(1);
         this._teamContributeMc["txt"].text = MainManager.actorInfo.teamInfo.canExContribution.toString();
         this._teamContributeMc["txt"].selectable = false;
         this._teamContributeMc["txt"].filters = [new GlowFilter(16777215,1,2,2,20)];
         if(MainManager.actorInfo.teamInfo.canExContribution > 10)
         {
            this._teamContributeMc["mc"].visible = true;
            this._teamContributeMc["mc"].gotoAndPlay(1);
         }
         ToolTipManager.add(this._teamContributeMc,"领取贡献度奖励");
         LevelManager.iconLevel.addChild(this._teamContributeMc);
         DisplayUtil.align(this._teamContributeMc,null,AlignType.MIDDLE_RIGHT,param1);
         this._teamContributeMc.addEventListener(MouseEvent.CLICK,this.onContributeClickHandler);
      }
      
      private function onContributeClickHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(MainManager.actorInfo.teamInfo.canExContribution < 10)
         {
            Alarm.show("你的贡献度还不够领取奖励，请再接再厉！");
            return;
         }
         Alert.show("你是否确定领取当前的所有贡献度奖励！",function():void
         {
            ArmManager.getContributeBounds(function():void
            {
               if(Boolean(_teamContributeMc))
               {
                  _teamContributeMc["txt"].text = MainManager.actorInfo.teamInfo.canExContribution.toString();
                  _teamContributeMc["mc"].visible = false;
                  _teamContributeMc["mc"].gotoAndStop(1);
               }
            });
         });
      }
      
      override public function destroy() : void
      {
         if(Boolean(this._editIcon))
         {
            ToolTipManager.remove(this._editIcon);
            this._editIcon.removeEventListener(MouseEvent.CLICK,this.onEdie);
            DisplayUtil.removeForParent(this._editIcon);
            this._editIcon = null;
         }
         if(Boolean(this._storageIcon))
         {
            ToolTipManager.remove(this._storageIcon);
            this._storageIcon.removeEventListener(MouseEvent.CLICK,this.onStorage);
            DisplayUtil.removeForParent(this._storageIcon);
            this._storageIcon = null;
         }
         if(Boolean(this._bookIcon))
         {
            ToolTipManager.remove(this._bookIcon);
            this._bookIcon.removeEventListener(MouseEvent.CLICK,this.onBook);
            DisplayUtil.removeForParent(this._bookIcon);
            this._bookIcon = null;
         }
         if(Boolean(this._saveIcon))
         {
            this._saveIcon.removeEventListener(MouseEvent.CLICK,this.onSave);
            ToolTipManager.remove(this._saveIcon);
            DisplayUtil.removeForParent(this._saveIcon);
            this._saveIcon = null;
         }
         if(this._isEdieing)
         {
            TweenLite.to(ToolBarController.panel,0.6,{
               "y":ToolBarController.panel.OLDY,
               "ease":Expo.easeOut
            });
         }
         if(Boolean(this._bookPanel))
         {
            this._bookPanel.destroy();
            this._bookPanel = null;
         }
         if(Boolean(this._infoIcon))
         {
            this._infoIcon.removeEventListener(MouseEvent.CLICK,this.onInfo);
            ToolTipManager.remove(this._infoIcon);
            DisplayUtil.removeForParent(this._infoIcon);
            this._infoIcon = null;
         }
         if(Boolean(this._infoPanel))
         {
            this._infoPanel.destroy();
            this._infoPanel = null;
         }
         if(Boolean(this._reallIcon))
         {
            ToolTipManager.remove(this._reallIcon);
            this._reallIcon.removeEventListener(MouseEvent.CLICK,this.onReAll);
            DisplayUtil.removeForParent(this._reallIcon);
            this._reallIcon = null;
         }
         if(Boolean(this._memberIcon))
         {
            this._memberIcon.removeEventListener(MouseEvent.CLICK,this.onMember);
            ToolTipManager.remove(this._memberIcon);
            DisplayUtil.removeForParent(this._memberIcon);
            this._memberIcon = null;
         }
         if(Boolean(this._memberPanel))
         {
            this._memberPanel.destroy();
            this._memberPanel = null;
         }
         if(Boolean(this._teamContributeMc))
         {
            ToolTipManager.remove(this._teamContributeMc);
            this._teamContributeMc.removeEventListener(MouseEvent.CLICK,this.onContributeClickHandler);
            DisplayUtil.removeForParent(this._teamContributeMc);
            this._teamContributeMc = null;
         }
         SocketConnection.removeCmdListener(CommandID.CONTRIBUTE_CHANGE,this.onChangeHandler);
         FortressStorageController.destroy();
         this._armShow.destroy();
         this._armShow = null;
         PetStorageController.destroy();
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         if(this._infoPanel == null)
         {
            this._infoPanel = ModuleManager.getModule(ClientConfig.getAppModule("TeamAdminPanel"),"正在打开战队资料...");
            this._infoPanel.setup();
         }
         this._infoPanel.init(MainManager.actorInfo.mapID);
         this._infoPanel.show();
      }
      
      private function teamInit() : void
      {
      }
      
      private function actorRoomInit() : void
      {
         this._bookIcon = UIManager.getButton("UI_Arm_Book_Icon");
         LevelManager.iconLevel.addChild(this._bookIcon);
         DisplayUtil.align(this._bookIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-50));
         ToolTipManager.add(this._bookIcon,"要塞手册");
         this._bookIcon.addEventListener(MouseEvent.CLICK,this.onBook);
         this._editIcon = UIManager.getButton("UI_Arm_Edit_Icon");
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.align(this._editIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,5));
         ToolTipManager.add(this._editIcon,"设置要塞");
         this._editIcon.addEventListener(MouseEvent.CLICK,this.onEdie);
         this._storageIcon = UIManager.getButton("UI_Arm_Storage_Icon");
         ToolTipManager.add(this._storageIcon,"要塞仓库");
         this._storageIcon.addEventListener(MouseEvent.CLICK,this.onStorage);
         this._armShow.getAllInfoForServer();
      }
      
      private function onBook(param1:MouseEvent) : void
      {
         if(this._bookPanel == null)
         {
            this._bookPanel = ModuleManager.getModule(ClientConfig.getBookModule("TeamBook"),"正在打开要塞手册...");
            this._bookPanel.setup();
         }
         this._bookPanel.show();
      }
      
      private function onEdie(param1:MouseEvent) : void
      {
         this._isEdieing = true;
         this._bookIcon.alpha = 0.4;
         this._bookIcon.mouseEnabled = false;
         this._armShow.openDrag();
         this._storageIcon.x = this._editIcon.x;
         this._storageIcon.y = this._editIcon.y;
         LevelManager.iconLevel.addChild(this._storageIcon);
         DisplayUtil.removeForParent(this._editIcon);
         if(this._reallIcon == null)
         {
            this._reallIcon = UIManager.getButton("UI_Arm_ReAll_Icon");
            this._reallIcon.x = this._storageIcon.x + 2;
            this._reallIcon.y = this._storageIcon.y + this._storageIcon.height + 10;
         }
         ToolTipManager.add(this._reallIcon,"重置");
         this._reallIcon.addEventListener(MouseEvent.CLICK,this.onReAll);
         LevelManager.iconLevel.addChild(this._reallIcon);
         if(this._saveIcon == null)
         {
            this._saveIcon = UIManager.getButton("UI_Arm_Save_Icon");
            this._saveIcon.x = this._reallIcon.x + 2;
            this._saveIcon.y = this._reallIcon.y + this._reallIcon.height + 10;
         }
         ToolTipManager.add(this._saveIcon,"保存设置");
         this._saveIcon.addEventListener(MouseEvent.CLICK,this.onSave);
         LevelManager.iconLevel.addChild(this._saveIcon);
         TweenLite.to(ToolBarController.panel,0.6,{
            "y":MainManager.getStageHeight() + 90,
            "ease":Expo.easeOut
         });
         this.onStorage(null);
      }
      
      private function onStorage(param1:MouseEvent) : void
      {
         FortressStorageController.show();
         ArmManager.storagePanel = FortressStorageController.panel;
      }
      
      private function onSave(param1:MouseEvent) : void
      {
         this._isEdieing = false;
         this._bookIcon.alpha = 1;
         this._bookIcon.mouseEnabled = true;
         this._armShow.closeDrag();
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.removeForParent(this._storageIcon);
         if(Boolean(this._saveIcon))
         {
            this._saveIcon.removeEventListener(MouseEvent.CLICK,this.onSave);
            ToolTipManager.remove(this._saveIcon);
            DisplayUtil.removeForParent(this._saveIcon);
            this._saveIcon = null;
         }
         if(Boolean(this._reallIcon))
         {
            ToolTipManager.remove(this._reallIcon);
            this._reallIcon.removeEventListener(MouseEvent.CLICK,this.onReAll);
            DisplayUtil.removeForParent(this._reallIcon);
            this._reallIcon = null;
         }
         FortressStorageController.hide();
         TweenLite.to(ToolBarController.panel,0.6,{
            "y":ToolBarController.panel.OLDY,
            "ease":Expo.easeOut
         });
         ArmManager.saveInfo();
      }
      
      private function onReAll(param1:MouseEvent) : void
      {
         ArmManager.removeAllInMap();
      }
      
      private function onMember(param1:MouseEvent) : void
      {
         if(this._memberPanel == null)
         {
            this._memberPanel = ModuleManager.getModule(ClientConfig.getAppModule("TeamMemberPanel"),"正在打开成员列表...");
            this._memberPanel.setup();
         }
         this._memberPanel.init(MainManager.actorInfo.mapID);
         this._memberPanel.show();
      }
   }
}

