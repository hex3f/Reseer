package com.robot.app.buyItem
{
   import com.robot.app.info.item.BuyItemInfo;
   import com.robot.app.info.item.BuyMultiItemInfo;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.GoldProductXMLInfo;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.MoneyProductXMLInfo;
   import com.robot.core.config.xml.PetShopXMLInfo;
   import com.robot.core.info.moneyAndGold.GoldBuyProductInfo;
   import com.robot.core.info.moneyAndGold.MoneyBuyProductInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.IconAlert;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class ItemCmdListener extends BaseBeanController
   {
      
      public static var ITEM_NAME:String;
      
      private static var THROW_THING:uint = 6;
      
      public function ItemCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.ITEM_BUY,this.onItemBuy);
         SocketConnection.addCmdListener(CommandID.MULTI_ITEM_BUY,this.onMultiItemBuy);
         SocketConnection.addCmdListener(CommandID.GOLD_BUY_PRODUCT,this.onBuyGoldProduct);
         SocketConnection.addCmdListener(CommandID.MONEY_BUY_PRODUCT,this.onBuyMoneyProduct);
         SocketConnection.addCmdListener(CommandID.EXCHANGE_GOLD_NIEOBEAN,this.onExchangeGold);
         finish();
      }
      
      private function onExchangeGold(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         var _loc5_:String = _loc4_.toString() + "金豆";
         IconAlert.show("你获得了" + TextFormatUtil.getRedTxt(_loc5_) + "，快去<font color=\'#ff0000\'>《宇宙购物指南》</font>中购物吧！^_^",5);
         if(_loc3_ == 1)
         {
            MainManager.actorInfo.coins -= 20000;
         }
         if(_loc3_ == 2)
         {
            MainManager.actorInfo.coins -= 40000;
         }
         if(_loc3_ == 3)
         {
            MainManager.actorInfo.coins -= 60000;
         }
      }
      
      private function onItemBuy(param1:SocketEvent) : void
      {
         var data:BuyItemInfo = null;
         var event:SocketEvent = param1;
         data = null;
         var str:String = null;
         data = event.data as BuyItemInfo;
         var name:String = ItemXMLInfo.getName(data.itemID);
         if(ItemXMLInfo.getCatID(data.itemID) == THROW_THING)
         {
            str = data.itemNum + "个<font color=\'#FF0000\'>" + name + "</font>已经放入你的投掷道具箱中";
            Alarm.show(str,function():void
            {
               EventManager.dispatchEvent(new DynamicEvent(ItemAction.BUY_ONE,data.itemID));
            });
         }
         else
         {
            str = data.itemNum + "个<font color=\'#FF0000\'>" + name + "</font>已经放入你的储存箱";
            ItemInBagAlert.show(data.itemID,str,function():void
            {
               EventManager.dispatchEvent(new DynamicEvent(ItemAction.BUY_ONE,data.itemID));
            });
         }
         MainManager.actorInfo.coins = data.cash;
      }
      
      private function onMultiItemBuy(param1:SocketEvent) : void
      {
         var _loc2_:BuyMultiItemInfo = param1.data as BuyMultiItemInfo;
         Alarm.show("<font color=\'#FF0000\'>" + ITEM_NAME + "</font>已经放入你的储存箱！");
         MainManager.actorInfo.coins = _loc2_.cash;
         EventManager.dispatchEvent(new Event(ItemAction.BUY_MUILTY));
      }
      
      private function onBuyGoldProduct(param1:SocketEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:String = null;
         var _loc4_:Array = [];
         var _loc5_:GoldBuyProductInfo = param1.data as GoldBuyProductInfo;
         _loc3_ = GoldProductXMLInfo.getNameByProID(ProductAction.productID);
         if(_loc3_ == "")
         {
            _loc4_ = PetShopXMLInfo.getItemIDs(ProductAction.productID);
         }
         else
         {
            _loc4_ = GoldProductXMLInfo.getItemIDs(ProductAction.productID);
         }
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = ItemXMLInfo.getName(_loc2_);
            if(_loc2_ > 500000)
            {
               IconAlert.show("恭喜你购买成功，" + TextFormatUtil.getRedTxt(_loc3_) + "已经放入你的基地仓库中",_loc2_);
            }
            else
            {
               ItemInBagAlert.show(_loc2_,"恭喜你购买成功，" + TextFormatUtil.getRedTxt(_loc3_) + "已经放入你的储存箱中");
            }
         }
      }
      
      private function onBuyMoneyProduct(param1:SocketEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:String = null;
         var _loc4_:MoneyBuyProductInfo = param1.data as MoneyBuyProductInfo;
         var _loc5_:Array = MoneyProductXMLInfo.getItemIDs(ProductAction.productID);
         for each(_loc2_ in _loc5_)
         {
            _loc3_ = ItemXMLInfo.getName(_loc2_);
            if(_loc2_ == 5)
            {
               _loc3_ = MoneyProductXMLInfo.getNameByProID(ProductAction.productID);
               IconAlert.show("你获得了" + TextFormatUtil.getRedTxt(_loc3_) + "，快去<font color=\'#ff0000\'>《宇宙购物指南》</font>中购物吧！^_^",_loc2_);
            }
            else if(_loc2_ > 500000)
            {
               IconAlert.show("恭喜你购买成功，" + TextFormatUtil.getRedTxt(_loc3_) + "已经放入你的基地仓库中",_loc2_);
            }
            else
            {
               ItemInBagAlert.show(_loc2_,"恭喜你购买成功，" + TextFormatUtil.getRedTxt(_loc3_) + "已经放入你的储存箱中");
            }
         }
      }
   }
}

