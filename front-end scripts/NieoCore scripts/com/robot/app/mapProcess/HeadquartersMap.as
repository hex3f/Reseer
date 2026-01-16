package com.robot.app.mapProcess
{
   import com.robot.app.sceneInteraction.*;
   import com.robot.app.storage.*;
   import com.robot.app.toolBar.*;
   import com.robot.core.config.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.*;
   import gs.*;
   import gs.easing.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class HeadquartersMap extends BaseMapProcess
   {
      
      private var _storageIcon:SimpleButton;
      
      private var _editIcon:SimpleButton;
      
      private var _saveIcon:SimpleButton;
      
      private var _bookIcon:SimpleButton;
      
      private var _reallIcon:SimpleButton;
      
      private var _infoIcon:SimpleButton;
      
      private var _isEdieing:Boolean = false;
      
      private var _headShow:HeadquarterShow;
      
      private var _bookPanel:AppModel;
      
      private var _door:Sprite;
      
      private var _infoPanel:AppModel;
      
      public function HeadquartersMap()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._door = conLevel["door_0"];
         ToolTipManager.add(this._door,"要塞");
         this._headShow = new HeadquarterShow();
         this._infoIcon = UIManager.getButton("UI_Arm_FightInfo_Icon");
         LevelManager.iconLevel.addChild(this._infoIcon);
         DisplayUtil.align(this._infoIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-110));
         ToolTipManager.add(this._infoIcon,"战队信息");
         this._infoIcon.addEventListener(MouseEvent.CLICK,this.onInfo);
         if(MainManager.actorInfo.teamInfo.id == MainManager.actorInfo.mapID)
         {
            if(MainManager.actorInfo.teamInfo.priv < 5)
            {
               this.teamInit();
            }
            if(MainManager.actorInfo.teamInfo.priv != 0)
            {
               return;
            }
            this.actorRoomInit();
            return;
         }
      }
      
      override public function destroy() : void
      {
         ToolTipManager.remove(this._door);
         this._door = null;
         this.removeEvent();
         this._headShow.destroy();
         this._headShow = null;
         if(Boolean(this._editIcon))
         {
            DisplayUtil.removeForParent(this._editIcon);
            this._editIcon = null;
         }
         if(Boolean(this._storageIcon))
         {
            DisplayUtil.removeForParent(this._storageIcon);
            this._storageIcon = null;
         }
         if(Boolean(this._bookIcon))
         {
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
         if(Boolean(this._reallIcon))
         {
            ToolTipManager.remove(this._reallIcon);
            this._reallIcon.removeEventListener(MouseEvent.CLICK,this.onReAll);
            DisplayUtil.removeForParent(this._reallIcon);
            this._reallIcon = null;
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
      }
      
      private function removeEvent() : void
      {
         if(Boolean(this._editIcon))
         {
            ToolTipManager.remove(this._editIcon);
            this._editIcon.removeEventListener(MouseEvent.CLICK,this.onEdie);
         }
         if(Boolean(this._storageIcon))
         {
            ToolTipManager.remove(this._storageIcon);
            this._storageIcon.removeEventListener(MouseEvent.CLICK,this.onStorage);
         }
         if(Boolean(this._bookIcon))
         {
            ToolTipManager.remove(this._bookIcon);
            this._bookIcon.removeEventListener(MouseEvent.CLICK,this.onBook);
         }
      }
      
      private function teamInit() : void
      {
         this._bookIcon = UIManager.getButton("UI_Arm_Book_Icon");
         LevelManager.iconLevel.addChild(this._bookIcon);
         DisplayUtil.align(this._bookIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-55));
         ToolTipManager.add(this._bookIcon,"总部手册");
         this._bookIcon.addEventListener(MouseEvent.CLICK,this.onBook);
      }
      
      private function actorRoomInit() : void
      {
         this._editIcon = UIManager.getButton("UI_Arm_Edit_Icon");
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.align(this._editIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,0));
         this._storageIcon = UIManager.getButton("UI_Arm_Storage_Icon");
         if(Boolean(this._editIcon))
         {
            ToolTipManager.add(this._editIcon,"设置总部");
            this._editIcon.addEventListener(MouseEvent.CLICK,this.onEdie);
         }
         if(Boolean(this._storageIcon))
         {
            ToolTipManager.add(this._storageIcon,"总部仓库");
            this._storageIcon.addEventListener(MouseEvent.CLICK,this.onStorage);
         }
         this._headShow.getStorageInfo();
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
      
      private function onBook(param1:MouseEvent) : void
      {
         if(this._bookPanel == null)
         {
            this._bookPanel = ModuleManager.getModule(ClientConfig.getBookModule("HeadquartersBook"),"正在打开总部手册");
            this._bookPanel.setup();
         }
         this._bookPanel.show();
      }
      
      private function onEdie(param1:MouseEvent) : void
      {
         this._isEdieing = true;
         this._bookIcon.alpha = 0.4;
         this._bookIcon.mouseEnabled = false;
         this._headShow.openDrag();
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
            "y":MainManager.getStageHeight(),
            "ease":Expo.easeOut
         });
         this.onStorage(null);
      }
      
      private function onStorage(param1:MouseEvent) : void
      {
         HeadquartersStorageController.show();
         HeadquarterManager.storagePanel = HeadquartersStorageController.panel;
      }
      
      private function onSave(param1:MouseEvent) : void
      {
         this._isEdieing = false;
         this._bookIcon.alpha = 1;
         this._bookIcon.mouseEnabled = true;
         this._headShow.closeDrag();
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.removeForParent(this._storageIcon);
         if(Boolean(this._saveIcon))
         {
            this._saveIcon.removeEventListener(MouseEvent.CLICK,this.onSave);
            ToolTipManager.remove(this._saveIcon);
            DisplayUtil.removeForParent(this._saveIcon);
         }
         if(Boolean(this._reallIcon))
         {
            ToolTipManager.remove(this._reallIcon);
            this._reallIcon.removeEventListener(MouseEvent.CLICK,this.onReAll);
            DisplayUtil.removeForParent(this._reallIcon);
            this._reallIcon = null;
         }
         HeadquartersStorageController.hide();
         TweenLite.to(ToolBarController.panel,0.6,{
            "y":ToolBarController.panel.OLDY,
            "ease":Expo.easeOut
         });
         HeadquarterManager.saveInfo();
      }
      
      public function onGotoMap() : void
      {
         MapManager.changeMap(MainManager.actorInfo.mapID,0,MapType.CAMP);
      }
      
      private function onReAll(param1:MouseEvent) : void
      {
         HeadquarterManager.removeAllInMap();
      }
   }
}

