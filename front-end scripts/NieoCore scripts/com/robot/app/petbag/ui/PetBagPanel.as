package com.robot.app.petbag.ui
{
   import com.robot.app.petbag.petPropsBag.PetBagModel;
   import com.robot.app.petbag.petPropsBag.ui.PetPropsPanel;
   import com.robot.app.picturebook.PictureBookController;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.uic.UIPanel;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetBagPanel extends UIPanel
   {
      
      private static const LIST_LENGTH:int = 6;
      
      private var _listCon:Sprite;
      
      private var _followBtn:MovieClip;
      
      private var _defaultBtn:SimpleButton;
      
      private var _storageBtn:SimpleButton;
      
      private var _pictureBookBtn:SimpleButton;
      
      private var _cureBtn:SimpleButton;
      
      private var _itemBtn:SimpleButton;
      
      private var _infoMc:PetDataPanel;
      
      private var _petPropsPanel:PetPropsPanel;
      
      private var _petBagModel:PetBagModel;
      
      private var _listData:Array;
      
      private var _curretItem:PetBagListItem;
      
      private var _arrowMc:MovieClip;
      
      private var _maskMc:Sprite;
      
      public function PetBagPanel()
      {
         var _loc1_:PetBagListItem = null;
         _loc1_ = null;
         super(UIManager.getSprite("PetBagMc"));
         this._followBtn = _mainUI["followBtn"];
         this._defaultBtn = _mainUI["defaultBtn"];
         this._storageBtn = _mainUI["storageBtn"];
         this._pictureBookBtn = _mainUI["pictureBookBtn"];
         this._cureBtn = _mainUI["cureBtn"];
         this._itemBtn = _mainUI["itemBtn"];
         addChild(_mainUI);
         this._followBtn.gotoAndStop(1);
         this._listCon = new Sprite();
         this._listCon.x = 30;
         this._listCon.y = 70;
         addChild(this._listCon);
         var _loc2_:int = 0;
         while(_loc2_ < LIST_LENGTH)
         {
            _loc1_ = new PetBagListItem();
            _loc1_.y = (_loc1_.height + 6) * int(_loc2_ / 2);
            _loc1_.x = (_loc1_.width + 6) * (_loc2_ % 2);
            this._listCon.addChild(_loc1_);
            _loc2_++;
         }
         this._infoMc = new PetDataPanel(_mainUI["infoMc"]);
         this._petPropsPanel = new PetPropsPanel(_mainUI["itemMC"]);
         var _loc3_:SimpleButton = _mainUI["itemMC"]["closeBtn"];
         _loc3_.addEventListener(MouseEvent.CLICK,this.showInfoPanel);
      }
      
      public function show() : void
      {
         this.showInfoPanel(null);
         _show();
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         PetManager.upDate();
      }
      
      override public function hide() : void
      {
         super.hide();
         this.openEvent();
         this._infoMc.hide();
         this._curretItem = null;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._infoMc = null;
         this._listCon = null;
         this._curretItem = null;
         this._followBtn = null;
         this._defaultBtn = null;
         this._storageBtn = null;
         this._pictureBookBtn = null;
         this._arrowMc = null;
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         this._followBtn.addEventListener(MouseEvent.CLICK,this.onFollow);
         this._defaultBtn.addEventListener(MouseEvent.CLICK,this.onDefault);
         this._storageBtn.addEventListener(MouseEvent.CLICK,this.onStorage);
         this._pictureBookBtn.addEventListener(MouseEvent.CLICK,this.onBook);
         this._cureBtn.addEventListener(MouseEvent.CLICK,this.onCure);
         this._itemBtn.addEventListener(MouseEvent.CLICK,this.onItemBag);
         PetManager.addEventListener(PetEvent.SET_DEFAULT,this.onUpDate);
         PetManager.addEventListener(PetEvent.UPDATE_INFO,this.onUpDate);
         PetManager.addEventListener(PetEvent.ADDED,this.onUpDate);
         PetManager.addEventListener(PetEvent.REMOVED,this.onUpDate);
         PetManager.addEventListener(PetEvent.CURE_ONE_COMPLETE,this.onUpDate);
         ToolTipManager.add(this._followBtn,"身边跟随");
         ToolTipManager.add(this._storageBtn,"放回仓库");
         ToolTipManager.add(this._pictureBookBtn,"精灵图鉴");
         ToolTipManager.add(this._cureBtn,"精灵恢复");
         ToolTipManager.add(this._itemBtn,"道具");
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         this._followBtn.removeEventListener(MouseEvent.CLICK,this.onFollow);
         this._defaultBtn.removeEventListener(MouseEvent.CLICK,this.onDefault);
         this._storageBtn.removeEventListener(MouseEvent.CLICK,this.onStorage);
         this._pictureBookBtn.removeEventListener(MouseEvent.CLICK,this.onBook);
         this._cureBtn.removeEventListener(MouseEvent.CLICK,this.onCure);
         this._itemBtn.removeEventListener(MouseEvent.CLICK,this.onItemBag);
         PetManager.removeEventListener(PetEvent.SET_DEFAULT,this.onUpDate);
         PetManager.removeEventListener(PetEvent.UPDATE_INFO,this.onUpDate);
         PetManager.removeEventListener(PetEvent.ADDED,this.onUpDate);
         PetManager.removeEventListener(PetEvent.REMOVED,this.onUpDate);
         PetManager.removeEventListener(PetEvent.CURE_ONE_COMPLETE,this.onUpDate);
         ToolTipManager.remove(this._followBtn);
         ToolTipManager.remove(this._storageBtn);
         ToolTipManager.remove(this._defaultBtn);
         ToolTipManager.remove(this._pictureBookBtn);
         ToolTipManager.remove(this._cureBtn);
         ToolTipManager.remove(this._itemBtn);
      }
      
      public function refreshItem() : void
      {
         var _loc1_:PetBagListItem = null;
         var _loc2_:PetInfo = null;
         var _loc3_:PetBagListItem = null;
         var _loc4_:int = 0;
         while(_loc4_ < LIST_LENGTH)
         {
            _loc1_ = this._listCon.getChildAt(_loc4_) as PetBagListItem;
            _loc1_.mouseEnabled = false;
            _loc1_.hide();
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc4_++;
         }
         var _loc5_:Array = PetManager.infos;
         _loc5_.sortOn("isDefault",Array.DESCENDING);
         var _loc6_:int = Math.min(LIST_LENGTH,PetManager.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc2_ = _loc5_[_loc7_] as PetInfo;
            _loc3_ = this._listCon.getChildAt(_loc7_) as PetBagListItem;
            _loc3_.show(_loc2_);
            _loc3_.name = _loc2_.id.toString();
            _loc3_.mouseEnabled = true;
            _loc3_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc7_++;
         }
         if(_loc6_ == 0)
         {
            this._followBtn.alpha = 0.4;
            this._followBtn.mouseEnabled = false;
            this._defaultBtn.alpha = 0.4;
            this._defaultBtn.mouseEnabled = false;
            this._storageBtn.alpha = 0.4;
            this._storageBtn.mouseEnabled = false;
            this._cureBtn.alpha = 0.4;
            this._cureBtn.mouseEnabled = false;
            this._itemBtn.alpha = 0.4;
            this._itemBtn.mouseEnabled = false;
            this._infoMc.clearInfo();
            return;
         }
         this._followBtn.alpha = 1;
         this._followBtn.mouseEnabled = true;
         this._defaultBtn.alpha = 1;
         this._defaultBtn.mouseEnabled = true;
         this._storageBtn.alpha = 1;
         this._storageBtn.mouseEnabled = true;
         this._cureBtn.alpha = 1;
         this._cureBtn.mouseEnabled = true;
         this._itemBtn.alpha = 1;
         this._itemBtn.mouseEnabled = true;
         if(this._curretItem == null || this._curretItem.info == null)
         {
            this._curretItem = this._listCon.getChildAt(0) as PetBagListItem;
            this._curretItem.setDefault(true);
         }
         else
         {
            (this._listCon.getChildAt(0) as PetBagListItem).setDefault(true);
         }
         this.setSelect(this._curretItem);
      }
      
      private function setSelect(param1:PetBagListItem) : void
      {
         if(Boolean(this._curretItem))
         {
            this._curretItem.isSelect = false;
         }
         if(param1.info.catchTime == PetManager.defaultTime)
         {
            this._defaultBtn.alpha = 0.4;
            ToolTipManager.remove(this._defaultBtn);
            this._defaultBtn.removeEventListener(MouseEvent.CLICK,this.onDefault);
         }
         else
         {
            this._defaultBtn.alpha = 1;
            ToolTipManager.add(this._defaultBtn,"设为首选");
            this._defaultBtn.addEventListener(MouseEvent.CLICK,this.onDefault);
         }
         this._curretItem = param1;
         this._curretItem.isSelect = true;
         this._infoMc.show(this._curretItem.info);
         this._petPropsPanel.getPetInfo(this._curretItem.info);
         this.upDateBtnState();
      }
      
      private function upDateBtnState() : void
      {
         if(Boolean(PetManager.showInfo))
         {
            if(this._curretItem.info.catchTime == PetManager.showInfo.catchTime)
            {
               this._followBtn.gotoAndStop(2);
               ToolTipManager.add(this._followBtn,"放入包内");
            }
            else
            {
               this._followBtn.gotoAndStop(1);
               ToolTipManager.add(this._followBtn,"身边跟随");
            }
         }
         else
         {
            this._followBtn.gotoAndStop(1);
            ToolTipManager.add(this._followBtn,"身边跟随");
         }
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:PetBagListItem = param1.currentTarget as PetBagListItem;
         this.setSelect(_loc2_);
      }
      
      private function onFollow(param1:MouseEvent) : void
      {
         if(PetManager.length == 0)
         {
            Alarm.show("你还没有赛尔精灵");
            return;
         }
         PetManager.showPet(this._curretItem.info.catchTime);
         if(this._followBtn.currentFrame == 1)
         {
            this._followBtn.gotoAndStop(2);
            ToolTipManager.add(this._followBtn,"放入包内");
            this.hide();
         }
         else
         {
            this._followBtn.gotoAndStop(1);
            ToolTipManager.add(this._followBtn,"身边跟随");
         }
      }
      
      private function onDefault(param1:MouseEvent) : void
      {
         PetManager.setDefault(this._curretItem.info.catchTime);
      }
      
      private function onStorage(param1:MouseEvent) : void
      {
         if(Boolean(this._curretItem))
         {
            PetManager.bagToInStorage(this._curretItem.info.catchTime);
         }
      }
      
      private function onBook(param1:MouseEvent) : void
      {
         PictureBookController.show();
      }
      
      private function onItemBag(param1:MouseEvent) : void
      {
         this._infoMc.hide();
         this._petPropsPanel = new PetPropsPanel(_mainUI["itemMC"]);
         this._petBagModel = new PetBagModel(this._petPropsPanel);
         (_mainUI["itemMC"] as MovieClip).visible = true;
         this.setSelect(this._curretItem);
      }
      
      private function showInfoPanel(param1:MouseEvent) : void
      {
         (_mainUI["infoMc"] as MovieClip).visible = true;
         (_mainUI["itemMC"] as MovieClip).visible = false;
      }
      
      private function onCure(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(Boolean(this._curretItem))
         {
            if(MainManager.actorInfo.superNono != 1)
            {
               Alert.show("单个精灵体力恢复要花费20赛尔豆\r你是否要给<font color=\'#ff0000\'>" + PetXMLInfo.getName(this._curretItem.info.id) + "</font>恢复体力？",function():void
               {
                  PetManager.cure(_curretItem.info.catchTime);
               });
            }
            else
            {
               PetManager.cure(this._curretItem.info.catchTime);
            }
         }
      }
      
      private function onUpDate(param1:PetEvent) : void
      {
         this.refreshItem();
      }
      
      public function closeEvent() : void
      {
         this._maskMc = new Sprite();
         this._maskMc.alpha = 0;
         this._maskMc.graphics.lineStyle(1,0);
         this._maskMc.graphics.beginFill(0);
         this._maskMc.graphics.drawRect(0,0,this.width,this.height);
         this._maskMc.graphics.endFill();
         this.addChild(this._maskMc);
         this.addChild(closeBtn);
         this._arrowMc = TaskIconManager.getIcon("Arrows_MC") as MovieClip;
         this.addChild(this._arrowMc);
         this._arrowMc.x = closeBtn.x;
         this._arrowMc.y = closeBtn.y + closeBtn.height + 5;
         MovieClip(this._arrowMc["mc"]).rotation = -180;
         MovieClip(this._arrowMc["mc"]).play();
      }
      
      public function openEvent() : void
      {
         if(Boolean(this._maskMc))
         {
            DisplayUtil.removeForParent(this._maskMc);
            this._maskMc = null;
         }
         if(Boolean(this._arrowMc))
         {
            DisplayUtil.removeForParent(this._arrowMc);
         }
      }
      
      public function get curretItem() : PetBagListItem
      {
         return this._curretItem;
      }
   }
}

