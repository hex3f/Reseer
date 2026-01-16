package com.robot.core.energyExchange
{
   import com.robot.core.CommandID;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   public class ExchangeOreModel
   {
      
      private static var _sucHandler:Function;
      
      private static var _handler:Function;
      
      private static var _desStr:String;
      
      private static var _infoMap:HashMap;
      
      private static var xmlClass:Class = ExchangeOreModel_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function ExchangeOreModel()
      {
         super();
      }
      
      public static function getData(param1:Function, param2:String) : void
      {
         _sucHandler = param1;
         _desStr = param2;
         _infoMap = new HashMap();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,onList);
         ItemManager.getCollection();
      }
      
      private static function onList(param1:ItemEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         var _loc3_:ExchangeItemInfo = null;
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,onList);
         var _loc4_:int = 0;
         while(_loc4_ < xml.item.length())
         {
            _loc2_ = ItemManager.getCollectionInfo(uint(xml.item[_loc4_].@id));
            if(Boolean(_loc2_))
            {
               _loc3_ = new ExchangeItemInfo(_loc2_);
               _infoMap.add(_loc3_.itemId,_loc3_);
            }
            _loc4_++;
         }
         if(_infoMap.length == 0)
         {
            if(_desStr != "")
            {
               Alarm.show(_desStr);
            }
            _sucHandler(null);
         }
         else
         {
            _sucHandler(_infoMap);
         }
      }
      
      public static function exchangeEnergy(param1:uint, param2:uint, param3:Function) : void
      {
         _handler = param3;
         SocketConnection.addCmdListener(CommandID.ITEM_SALE,onSuccess);
         SocketConnection.send(CommandID.ITEM_SALE,param1,param2);
      }
      
      private static function onSuccess(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.ITEM_SALE,onSuccess);
         _handler();
      }
   }
}

