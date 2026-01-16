package com.robot.app.buyItem
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.IconAlert;
   import flash.utils.ByteArray;
   
   public class ItemAction
   {
      
      private static var _buyApp:AppModel;
      
      public static const FLAG_IN_BAG:uint = 0;
      
      public static const FLAG_ON_BODY:uint = 1;
      
      public static const FLAG_ALL:uint = 2;
      
      public static const BUY_ONE:String = "buyOne";
      
      public static const BUY_MUILTY:String = "buyMuilty";
      
      public function ItemAction()
      {
         super();
      }
      
      public static function listItem(param1:uint = 100001, param2:uint = 101001, param3:uint = 2) : void
      {
         SocketConnection.send(CommandID.ITEM_LIST,param1,param2,param3);
      }
      
      public static function showBuyPanel(param1:uint) : void
      {
         if(!_buyApp)
         {
            _buyApp = new AppModel(ClientConfig.getAppModule("BuyItemTipPanel"),"正在打开购买面板");
            _buyApp.setup();
         }
         _buyApp.init(param1);
         _buyApp.show();
      }
      
      public static function desBuyPanel() : void
      {
         if(Boolean(_buyApp))
         {
            _buyApp.destroy();
            _buyApp = null;
         }
      }
      
      public static function buyItem(param1:uint, param2:Boolean = true, param3:uint = 1) : void
      {
         var price:uint = 0;
         var name:String = null;
         var str:String = null;
         var id:uint = param1;
         var isTip:Boolean = param2;
         var count:uint = param3;
         if(ItemXMLInfo.getVipOnly(id))
         {
            if(!MainManager.actorInfo.vip)
            {
               Alarm.show("你还没有开通超能NoNo，不能购买这个装备哦！");
               return;
            }
         }
         if(!isTip)
         {
            SocketConnection.send(CommandID.ITEM_BUY,id,count);
            return;
         }
         price = uint(ItemXMLInfo.getPrice(id));
         name = ItemXMLInfo.getName(id);
         str = "";
         if(count > 1)
         {
            str += count + "个";
         }
         if(price > 0)
         {
            if(MainManager.isClothHalfDay)
            {
               str += "<font color=\'#ff0000\'>" + name + "</font>需要花费" + price.toString() + "赛尔豆，<font color=\'#ff0000\'>（半价日只需要花费" + price / 2 + "赛尔豆）</font>，要确定购买吗？";
            }
            else
            {
               str += "<font color=\'#ff0000\'>" + name + "</font>需要花费" + price * count + "赛尔豆，" + "你现在拥有" + MainManager.actorInfo.coins + "赛尔豆，要确定购买吗？";
            }
         }
         else
         {
            str += "<font color=\'#ff0000\'>" + name + "</font>免费赠送，你确定现在就要领取吗？";
         }
         IconAlert.show(str,id,function():void
         {
            SocketConnection.send(CommandID.ITEM_BUY,id,count);
         });
      }
      
      public static function buyMultiItem(param1:uint, param2:String, ... rest) : void
      {
         var _loc4_:Number = 0;
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.writeUnsignedInt(param1);
         for each(_loc4_ in rest)
         {
            _loc5_.writeUnsignedInt(_loc4_);
         }
         ItemCmdListener.ITEM_NAME = param2;
         SocketConnection.send(CommandID.MULTI_ITEM_BUY,_loc5_);
      }
   }
}

