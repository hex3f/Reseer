package com.robot.app.mapProcess
{
   import com.robot.app.petSimulationTraining.*;
   import com.robot.app.sceneInteraction.*;
   import com.robot.app.storage.*;
   import com.robot.app.toolBar.*;
   import com.robot.app.user.*;
   import com.robot.core.config.*;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import gs.*;
   import gs.easing.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class RoomMap extends BaseMapProcess
   {
      
      private var _petStorageIcon:SimpleButton;
      
      private var _storageIcon:SimpleButton;
      
      private var _editIcon:SimpleButton;
      
      private var _saveIcon:SimpleButton;
      
      private var _bookIcon:SimpleButton;
      
      private var _isEdieing:Boolean = false;
      
      private var _roomFitment:RoomFitment;
      
      private var _bookPanel:AppModel;
      
      private var _roomPet:RoomPetShow;
      
      private var _roomNono:RoomMachShow;
      
      private var _doorplate:Sprite;
      
      public function RoomMap()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.doorplateShow(topLevel.getChildByName("menpaiMc") as Sprite);
         this._roomFitment = new RoomFitment();
         this._roomPet = new RoomPetShow(MainManager.actorInfo.mapID);
         this._roomNono = new RoomMachShow(MainManager.actorInfo.mapID);
         if(MainManager.actorID != MainManager.actorInfo.mapID)
         {
            return;
         }
         this.actorRoomInit();
         if(TasksManager.getTaskStatus(123) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(123);
         }
      }
      
      private function addEvent() : void
      {
         if(Boolean(this._editIcon))
         {
            ToolTipManager.add(this._editIcon,"设置基地");
            this._editIcon.addEventListener(MouseEvent.CLICK,this.onEdie);
         }
         if(Boolean(this._storageIcon))
         {
            ToolTipManager.add(this._storageIcon,"仓库");
            this._storageIcon.addEventListener(MouseEvent.CLICK,this.onStorage);
         }
         if(Boolean(this._bookIcon))
         {
            ToolTipManager.add(this._bookIcon,"基地手册");
            this._bookIcon.addEventListener(MouseEvent.CLICK,this.onBook);
         }
         if(Boolean(this._petStorageIcon))
         {
            ToolTipManager.add(this._petStorageIcon,"精灵仓库");
            this._petStorageIcon.addEventListener(MouseEvent.CLICK,this.onPetStorage);
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
         if(Boolean(this._petStorageIcon))
         {
            ToolTipManager.remove(this._petStorageIcon);
            this._petStorageIcon.removeEventListener(MouseEvent.CLICK,this.onPetStorage);
         }
      }
      
      private function actorRoomInit() : void
      {
         this._editIcon = UIManager.getButton("Room_Edit_Icon");
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.align(this._editIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,0));
         this._storageIcon = UIManager.getButton("Room_Storage_Icon");
         this._bookIcon = UIManager.getButton("Room_Book_Icon");
         LevelManager.iconLevel.addChild(this._bookIcon);
         DisplayUtil.align(this._bookIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-this._storageIcon.height - 10));
         this._petStorageIcon = UIManager.getButton("PetStorage_Icon");
         LevelManager.iconLevel.addChild(this._petStorageIcon);
         DisplayUtil.align(this._petStorageIcon,null,AlignType.MIDDLE_RIGHT,new Point(-10,-this._storageIcon.height - this._bookIcon.height - 20));
         this.addEvent();
         this._roomFitment.getStorageInfo();
      }
      
      private function doorplateShow(param1:Sprite) : void
      {
         var ui:Sprite = param1;
         if(Boolean(ui))
         {
            this._doorplate = ui;
            this._doorplate.buttonMode = true;
            ui["txt"].text = "";
            UserInfoManager.seeOnLine([MainManager.actorInfo.mapID],function(param1:Array):void
            {
               var arr:Array = param1;
               if(arr.length == 0)
               {
                  ui["txt"].text = MainManager.actorInfo.mapID.toString();
               }
               else
               {
                  UserInfoManager.getInfo(arr[0].userID,function(param1:UserInfo):void
                  {
                     ui["txt"].text = param1.nick;
                  });
               }
               _doorplate.addEventListener(MouseEvent.CLICK,onDoorPlateInfo);
            });
         }
      }
      
      override public function destroy() : void
      {
         this.removeEvent();
         PetSimulationTrainingController.destroy();
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
         if(Boolean(this._petStorageIcon))
         {
            DisplayUtil.removeForParent(this._petStorageIcon);
            this._petStorageIcon = null;
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
         this._roomPet.destroy();
         this._roomPet = null;
         StorageController.destroy();
         this._roomFitment.destroy();
         this._roomFitment = null;
         PetStorageController.destroy();
         this._roomNono.destroy();
         if(Boolean(this._doorplate))
         {
            this._doorplate.removeEventListener(MouseEvent.CLICK,this.onDoorPlateInfo);
            this._doorplate = null;
         }
      }
      
      private function onDoorPlateInfo(param1:MouseEvent) : void
      {
         UserInfoController.show(MainManager.actorInfo.mapID);
      }
      
      private function onBook(param1:MouseEvent) : void
      {
         if(this._bookPanel == null)
         {
            this._bookPanel = ModuleManager.getModule(ClientConfig.getBookModule("RoomBook"),"正在打开基地手册");
            this._bookPanel.setup();
         }
         this._bookPanel.show();
      }
      
      private function onEdie(param1:MouseEvent) : void
      {
         this._isEdieing = true;
         this._bookIcon.alpha = 0.4;
         this._bookIcon.mouseEnabled = false;
         this._roomFitment.openDrag();
         this._storageIcon.x = this._editIcon.x;
         this._storageIcon.y = this._editIcon.y;
         LevelManager.iconLevel.addChild(this._storageIcon);
         DisplayUtil.removeForParent(this._editIcon);
         if(this._saveIcon == null)
         {
            this._saveIcon = UIManager.getButton("Room_Save_Icon");
            this._saveIcon.x = this._storageIcon.x + 2;
            this._saveIcon.y = this._storageIcon.y + this._storageIcon.height + 10;
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
         StorageController.show();
         FitmentManager.storagePanel = StorageController.panel;
      }
      
      private function onPetStorage(param1:MouseEvent) : void
      {
         PetStorageController.show();
      }
      
      private function onSave(param1:MouseEvent) : void
      {
         this._isEdieing = false;
         this._bookIcon.alpha = 1;
         this._bookIcon.mouseEnabled = true;
         this._roomFitment.closeDrag();
         LevelManager.iconLevel.addChild(this._editIcon);
         DisplayUtil.removeForParent(this._storageIcon);
         if(Boolean(this._saveIcon))
         {
            this._saveIcon.removeEventListener(MouseEvent.CLICK,this.onSave);
            ToolTipManager.remove(this._saveIcon);
            DisplayUtil.removeForParent(this._saveIcon);
         }
         StorageController.hide();
         TweenLite.to(ToolBarController.panel,0.6,{
            "y":ToolBarController.panel.OLDY,
            "ease":Expo.easeOut
         });
         FitmentManager.saveInfo();
      }
   }
}

