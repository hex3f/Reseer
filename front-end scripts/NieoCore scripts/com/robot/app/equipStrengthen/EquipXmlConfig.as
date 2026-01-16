package com.robot.app.equipStrengthen
{
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   
   public class EquipXmlConfig
   {
      
      private static var _allIdA:Array;
      
      private static var xmlClass:Class = EquipXmlConfig_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function EquipXmlConfig()
      {
         super();
      }
      
      public static function getAllEquipId() : Array
      {
         var _loc1_:XML = null;
         var _loc2_:XMLList = xml.elements("equip");
         _allIdA = new Array();
         for each(_loc1_ in _loc2_)
         {
            _allIdA.push(uint(_loc1_.@id));
         }
         return _allIdA;
      }
      
      public static function getInfo(param1:uint, param2:uint, param3:Function) : void
      {
         var info:EquipStrengthenInfo = null;
         var ownA:Array = null;
         var id:uint = param1;
         var lev:uint = param2;
         var func:Function = param3;
         var xmlList:XMLList = null;
         var xml1:XML = null;
         var xmlList1:XMLList = null;
         var xml2:XML = null;
         info = null;
         var needA:Array = null;
         ownA = null;
         xmlList = xml.elements("equip");
         xml1 = xmlList.(@id == id.toString())[0];
         xmlList1 = xml1.elements("level");
         xml2 = xmlList1.(@levelId == lev.toString())[0];
         if(xml2 == null)
         {
            return;
         }
         info = new EquipStrengthenInfo();
         info.itemId = id;
         info.levelId = lev;
         info.sendId = uint(xml2.@sendId);
         needA = String(xml2.@needCatalystId).split("|");
         info.needCatalystId = needA[0];
         info.needCatalystNum = needA[1];
         info.needMatterA = String(xml2.@needMatterId).split("|");
         info.needMatterNumA = String(xml2.@needMatterNum).split("|");
         info.des = xml2.@des;
         info.prob = xml2.@odds;
         ownA = new Array();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,function(param1:ItemEvent):void
         {
            var _loc3_:SingleItemInfo = null;
            ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,arguments.callee);
            var _loc4_:int = 0;
            while(_loc4_ < info.needMatterA.length)
            {
               _loc3_ = ItemManager.getCollectionInfo(info.needMatterA[_loc4_]);
               if(Boolean(_loc3_))
               {
                  ownA.push(_loc3_.itemNum);
               }
               else
               {
                  ownA.push(0);
               }
               _loc4_++;
            }
            var _loc5_:SingleItemInfo = ItemManager.getCollectionInfo(info.needCatalystId);
            if(Boolean(_loc5_))
            {
               info.ownCatalystNum = _loc5_.itemNum;
            }
            else
            {
               info.ownCatalystNum = 0;
            }
            info.ownNeedA = ownA;
            if(func != null)
            {
               func(info);
            }
         });
         ItemManager.getCollection();
      }
   }
}

