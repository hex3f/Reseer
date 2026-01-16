package com.robot.app.buyPetProps
{
   import com.robot.app.buyItem.ProductAction;
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.userItem.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.itemTip.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.text.*;
   import org.taomee.manager.*;
   
   public class ItemMC
   {
      
      private var _itemMC:MovieClip;
      
      private var _bgMC:MovieClip;
      
      private var _buyItemBtn:SimpleButton;
      
      private var _itemNameText:TextField;
      
      private var _itemPriceText:TextField;
      
      private var _seerCoinMC:MovieClip;
      
      private var _glodCoinMC:MovieClip;
      
      private var price:Number = 999999999;
      
      private var icon:Sprite = new Sprite();
      
      private var itemID:int = 0;
      
      private var isGoldCoinItem:Boolean = false;
      
      private var _parent:BuyPetPropsPanel;
      
      private var singleItemInfo:SingleItemInfo = new SingleItemInfo();
      
      public function ItemMC(param1:BuyPetPropsPanel, param2:int)
      {
         super();
         this._parent = param1;
         this._itemMC = new (param1.app.getDefinition("itemMC") as Class)() as MovieClip;
         this._itemMC.x = 85 + 100 * (param2 % 5);
         this._itemMC.y = 67 + 115 * int(param2 / 5);
         this._itemMC.name = "itemMC_" + param2.toString();
         this._bgMC = this._itemMC["bgMC"] as MovieClip;
         this._bgMC.addEventListener(MouseEvent.ROLL_OVER,this.showTip);
         this._bgMC.addEventListener(MouseEvent.ROLL_OUT,this.hideTip);
         this._itemNameText = this._itemMC["itemNameTxet"] as TextField;
         this._itemPriceText = this._itemMC["itemPriceText"] as TextField;
         this._seerCoinMC = this._itemMC["seerCoinMC"] as MovieClip;
         this._glodCoinMC = this._itemMC["goldCoinMC"] as MovieClip;
         this._buyItemBtn = this._itemMC["buyItemBtn"] as SimpleButton;
         this._buyItemBtn.addEventListener(MouseEvent.CLICK,this.onClickBuyBtn);
         this._glodCoinMC.visible = false;
         this._bgMC.addChild(this.icon);
         this.icon.mouseEnabled = false;
         this.icon.mouseChildren = false;
      }
      
      private function showTip(param1:MouseEvent) : void
      {
         ItemInfoTip.show(this.singleItemInfo);
      }
      
      private function hideTip(param1:MouseEvent) : void
      {
         ItemInfoTip.hide();
      }
      
      public function setup(param1:int) : void
      {
         var onLoadIcon:Function;
         var itemId:int = param1;
         this.itemID = itemId;
         this.singleItemInfo.itemID = itemId;
         this.isGoldCoinItem = PetShopXMLInfo.getMoneyTypeByItemID(this.itemID) == 1;
         this._seerCoinMC.visible = !this.isGoldCoinItem;
         this._glodCoinMC.visible = this.isGoldCoinItem;
         this._itemNameText.text = PetShopXMLInfo.getNameByItemID(this.itemID);
         this.price = PetShopXMLInfo.getPriceByItemID(this.itemID);
         this._itemPriceText.text = this.price.toString();
         while(this.icon.numChildren > 0)
         {
            this.icon.removeChildAt(0);
         }
         onLoadIcon = function(param1:DisplayObject):void
         {
            icon.addChild(param1);
         };
         ResourceManager.getResource(ItemXMLInfo.getIconURL(this.itemID),onLoadIcon);
      }
      
      public function onClickBuyBtn(param1:MouseEvent) : void
      {
         var onGetIcon:Function = null;
         var proID:uint = 0;
         var e:MouseEvent = param1;
         if(this.isGoldCoinItem)
         {
            this._parent.goldCoinItemID = this.itemID;
            proID = PetShopXMLInfo.getProductByItemId(this.itemID);
            ProductAction.buyGoldProduct(proID);
         }
         else
         {
            onGetIcon = function(param1:DisplayObject):void
            {
               _parent.showTipPanel(itemID,param1 as MovieClip,new Point(182,45));
            };
            ResourceManager.getResource(ItemXMLInfo.getIconURL(this.itemID),onGetIcon);
         }
      }
      
      public function get itemMC() : MovieClip
      {
         return this._itemMC;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._itemMC.visible = param1;
      }
      
      public function get name() : String
      {
         return this._itemMC.name;
      }
   }
}

