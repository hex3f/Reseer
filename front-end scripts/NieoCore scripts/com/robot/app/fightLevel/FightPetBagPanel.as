package com.robot.app.fightLevel
{
   import com.robot.app.petbag.ui.PetBagListItem;
   import com.robot.app.petbag.ui.PetDataPanel;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.uic.UIPanel;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class FightPetBagPanel extends UIPanel
   {
      
      private static const LIST_LENGTH:int = 6;
      
      private var _listCon:Sprite;
      
      private var _defaultBtn:SimpleButton;
      
      private var _cureBtn:SimpleButton;
      
      private var _infoMc:PetDataPanel;
      
      private var _listData:Array;
      
      private var _curretItem:PetBagListItem;
      
      public function FightPetBagPanel()
      {
         var _loc1_:PetBagListItem = null;
         super(UIManager.getSprite("PetBagMc"));
         this._defaultBtn = _mainUI["defaultBtn"];
         this._cureBtn = _mainUI["cureBtn"];
         _mainUI["itemBtn"].visible = false;
         _mainUI["followBtn"].visible = false;
         _mainUI["storageBtn"].visible = false;
         _mainUI["pictureBookBtn"].visible = false;
         _mainUI["itemMC"].visible = false;
         this._defaultBtn.x += 20;
         this._cureBtn.x -= 20;
         addChild(_mainUI);
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
      }
      
      public function show() : void
      {
         _show();
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         PetManager.upDate();
      }
      
      override public function hide() : void
      {
         super.hide();
         this._infoMc.hide();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._infoMc = null;
         this._listCon = null;
         this._curretItem = null;
         this._defaultBtn = null;
         this._cureBtn = null;
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         this._defaultBtn.addEventListener(MouseEvent.CLICK,this.onDefault);
         this._cureBtn.addEventListener(MouseEvent.CLICK,this.onCure);
         PetManager.addEventListener(PetEvent.SET_DEFAULT,this.onUpDate);
         PetManager.addEventListener(PetEvent.UPDATE_INFO,this.onUpDate);
         PetManager.addEventListener(PetEvent.ADDED,this.onUpDate);
         PetManager.addEventListener(PetEvent.REMOVED,this.onUpDate);
         PetManager.addEventListener(PetEvent.CURE_ONE_COMPLETE,this.onUpDate);
         ToolTipManager.add(this._cureBtn,"精灵恢复");
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         this._defaultBtn.removeEventListener(MouseEvent.CLICK,this.onDefault);
         this._cureBtn.removeEventListener(MouseEvent.CLICK,this.onCure);
         PetManager.removeEventListener(PetEvent.SET_DEFAULT,this.onUpDate);
         PetManager.removeEventListener(PetEvent.UPDATE_INFO,this.onUpDate);
         PetManager.removeEventListener(PetEvent.ADDED,this.onUpDate);
         PetManager.removeEventListener(PetEvent.REMOVED,this.onUpDate);
         PetManager.removeEventListener(PetEvent.CURE_ONE_COMPLETE,this.onUpDate);
         ToolTipManager.remove(this._defaultBtn);
         ToolTipManager.remove(this._cureBtn);
      }
      
      private function refreshItem() : void
      {
         var _loc3_:PetBagListItem = null;
         var _loc1_:PetBagListItem = null;
         var _loc2_:PetInfo = null;
         _loc3_ = null;
         this._curretItem = null;
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
            this._defaultBtn.alpha = 0.4;
            this._defaultBtn.mouseEnabled = false;
            this._cureBtn.alpha = 0.4;
            this._cureBtn.mouseEnabled = false;
            return;
         }
         this._defaultBtn.alpha = 1;
         this._defaultBtn.mouseEnabled = true;
         this._cureBtn.alpha = 1;
         this._cureBtn.mouseEnabled = true;
         this._curretItem = this._listCon.getChildAt(0) as PetBagListItem;
         this._curretItem.setDefault(true);
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
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:PetBagListItem = param1.currentTarget as PetBagListItem;
         this.setSelect(_loc2_);
      }
      
      private function onDefault(param1:MouseEvent) : void
      {
         PetManager.setDefault(this._curretItem.info.catchTime);
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
   }
}

