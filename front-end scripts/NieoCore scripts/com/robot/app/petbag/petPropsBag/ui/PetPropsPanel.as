package com.robot.app.petbag.petPropsBag.ui
{
   import com.robot.app.bag.BagListItem;
   import com.robot.app.petbag.PetBagController;
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.ui.itemTip.ItemInfoTip;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import org.taomee.events.SocketEvent;
   
   public class PetPropsPanel extends Sprite
   {
      
      public static const PREV_PAGE:String = "prevPage";
      
      public static const NEXT_PAGE:String = "nextPage";
      
      public static const SHOW_COLLECTION:String = "showCollection";
      
      private var _clickItemID:uint;
      
      private var petPropsPanel:Sprite;
      
      private var _listCon:Sprite;
      
      private var _itemArr:Array = [];
      
      private var _currentBagItem:BagListItem;
      
      private var _petInfo:PetInfo;
      
      private var itemID:uint;
      
      private var itemName:String;
      
      private var _propInfo:PetPropInfo;
      
      public function PetPropsPanel(param1:Sprite)
      {
         super();
         this.petPropsPanel = param1;
         this.show();
         this.addEvent();
      }
      
      public function hide() : void
      {
         this.petPropsPanel.visible = false;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function addEvent() : void
      {
      }
      
      public function showItem(param1:Array) : void
      {
         var _loc2_:* = 0;
         var _loc3_:BagListItem = null;
         var _loc4_:SingleItemInfo = null;
         var _loc5_:Boolean = false;
         this.clearItemPanel();
         var _loc6_:int = int(param1.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc2_ = uint(param1[_loc7_]);
            _loc3_ = this._listCon.getChildAt(_loc7_) as BagListItem;
            _loc4_ = ItemManager.getPetItemInfo(_loc2_);
            _loc5_ = false;
            _loc3_.buttonMode = true;
            _loc3_.setInfo(_loc4_,_loc5_);
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.onShowItemInfo);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onHideItemInfo);
            _loc3_.addEventListener(MouseEvent.CLICK,this.onPetPropsUsed);
            _loc7_++;
         }
      }
      
      public function show() : void
      {
         this._listCon = new Sprite();
         this._listCon.x = 50;
         this._listCon.y = 20;
         this.petPropsPanel.addChild(this._listCon);
         this.createItemPanel();
         var _loc1_:SimpleButton = this.petPropsPanel["prev_btn"];
         var _loc2_:SimpleButton = this.petPropsPanel["next_btn"];
         _loc1_.addEventListener(MouseEvent.CLICK,this.prevHandler);
         _loc2_.addEventListener(MouseEvent.CLICK,this.nextHandler);
      }
      
      private function createItemPanel() : void
      {
         var _loc1_:BagListItem = null;
         _loc1_ = null;
         var _loc2_:int = 0;
         while(_loc2_ < 12)
         {
            _loc1_ = new BagListItem(UIManager.getSprite("itemPanel"));
            _loc1_.x = (_loc1_.width + 10) * int(_loc2_ % 3);
            _loc1_.y = (_loc1_.height + 10) * int(_loc2_ / 3);
            this._listCon.addChild(_loc1_);
            _loc2_++;
         }
      }
      
      private function clearItemPanel() : void
      {
         var _loc1_:BagListItem = null;
         var _loc2_:int = this._listCon.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._listCon.getChildAt(_loc3_) as BagListItem;
            _loc1_.clear();
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.onShowItemInfo);
            _loc1_.removeEventListener(MouseEvent.ROLL_OUT,this.onHideItemInfo);
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onPetPropsUsed);
            _loc1_.buttonMode = false;
            _loc3_++;
         }
      }
      
      private function prevHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(PREV_PAGE));
      }
      
      private function nextHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(NEXT_PAGE));
      }
      
      public function setPageNum(param1:uint, param2:uint) : void
      {
         this.petPropsPanel["page_txt"].text = param1 + "/" + param2;
      }
      
      public function onPetPropsUsed(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(this._petInfo == null)
         {
            Alarm.show("你要先选择一个精灵噢");
            return;
         }
         this._currentBagItem = param1.currentTarget as BagListItem;
         if(this._currentBagItem.info == null)
         {
            return;
         }
         this.itemID = this._currentBagItem.info.itemID;
         this.itemName = ItemXMLInfo.getName(this.itemID);
         if(this.itemID == 300028 || this.itemID == 300035)
         {
            _loc2_ = "你确定要使用" + TextFormatUtil.getRedTxt(this.itemName) + "吗?";
         }
         else
         {
            _loc2_ = "你确定要为你的<font color=\'#ff0000\'>" + PetXMLInfo.getName(this._petInfo.id) + "</font>使用" + TextFormatUtil.getRedTxt(this.itemName) + "吗?";
            PetManager.handleCatchTime = this._petInfo.catchTime;
         }
         this._propInfo = new PetPropInfo();
         this._propInfo.petInfo = this._petInfo;
         this._propInfo.itemId = this.itemID;
         this._propInfo.itemName = this.itemName;
         Alert.show(_loc2_,this.onsureHandler);
      }
      
      private function onsureHandler() : void
      {
         var _loc1_:Object = null;
         try
         {
            SocketConnection.addCmdListener(CommandID.USE_PET_ITEM_FULL_ABILITY_OF_STUDY,this.onUpDate);
            SocketConnection.addCmdListener(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,this.onUpDate);
            _loc1_ = getDefinitionByName("com.robot.app.petbag.petPropsBag.petPropClass.PetPropClass_" + this.itemID);
            if(Boolean(_loc1_))
            {
               this.hide();
               new _loc1_(this._propInfo);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onUpDate(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.USE_PET_ITEM_FULL_ABILITY_OF_STUDY,this.onUpDate);
         SocketConnection.removeCmdListener(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,this.onUpDate);
         this.hide();
         PetManager.upDate();
         if(this._currentBagItem.info.itemNum > 0)
         {
            --this._currentBagItem.info.itemNum;
         }
         this._currentBagItem.setInfo(this._currentBagItem.info);
         var _loc2_:uint = uint(this._currentBagItem.info.itemID);
         if(_loc2_ == 300037 || _loc2_ == 300038 || _loc2_ == 300039 || _loc2_ == 300040 || _loc2_ == 300041 || _loc2_ == 300042)
         {
            PetBagController.panel.curretItem.showClear();
         }
      }
      
      private function onShowItemInfo(param1:MouseEvent) : void
      {
         var _loc2_:BagListItem = param1.currentTarget as BagListItem;
         if(_loc2_.info == null)
         {
            return;
         }
         this._clickItemID = _loc2_.info.itemID;
         ItemInfoTip.show(_loc2_.info);
      }
      
      private function onHideItemInfo(param1:MouseEvent) : void
      {
         ItemInfoTip.hide();
      }
      
      public function getPetInfo(param1:PetInfo) : PetInfo
      {
         this._petInfo = param1;
         return this._petInfo;
      }
      
      public function get clickItemID() : uint
      {
         return this._clickItemID;
      }
   }
}

