package com.robot.core.config.xml
{
   import org.taomee.ds.*;
   
   public class PetShopXMLInfo
   {
      
      private static var _xmllist:XMLList;
      
      private static var _itemMap:HashMap;
      
      private static var _productMap:HashMap;
      
      private static var xml:XML;
      
      private static var xmlClass:Class = PetShopXMLInfo_xmlClass;
      
      setup();
      
      public function PetShopXMLInfo()
      {
         super();
      }
      
      public static function setup() : void
      {
         var _loc1_:XML = null;
         _itemMap = new HashMap();
         _productMap = new HashMap();
         xml = XML(new xmlClass());
         _xmllist = xml.elements("item");
         for each(_loc1_ in _xmllist)
         {
            _itemMap.add(uint(_loc1_.@itemID),_loc1_);
            _productMap.add(_loc1_.@productID.toString(),_loc1_);
         }
      }
      
      public static function getItemIdArray() : Array
      {
         return _itemMap.getKeys();
      }
      
      public static function getItemIDs(param1:uint) : Array
      {
         var xml:XML = null;
         var str:String = null;
         var proID:uint = param1;
         xml = _xmllist.(@productID == proID)[0];
         str = xml.@itemID;
         return str.split("|");
      }
      
      public static function getNameByItemID(param1:uint) : String
      {
         var _loc2_:XML = _itemMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name;
         }
         return "";
      }
      
      public static function getPriceByItemID(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         try
         {
            xml = _xmllist.(@itemID == id)[0];
            return xml.@price;
         }
         catch(error:Error)
         {
            return 999999999;
         }
      }
      
      public static function getProductByItemId(param1:uint) : uint
      {
         var _loc2_:XML = _itemMap.getValue(param1.toString());
         if(_loc2_ == null)
         {
            return 0;
         }
         return uint(_loc2_.@productID);
      }
      
      public static function getPriceByProID(param1:uint) : Number
      {
         var xml:XML = null;
         var proID:uint = param1;
         xml = _xmllist.(@productID == proID)[0];
         return xml.@price;
      }
      
      public static function getNameByProID(param1:uint) : String
      {
         var _loc2_:XML = _productMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name;
         }
         return "";
      }
      
      public static function getMoneyTypeByItemID(param1:uint) : uint
      {
         var _loc2_:XML = _itemMap.getValue(param1.toString());
         if(_loc2_ == null)
         {
            return 0;
         }
         return uint(_loc2_.@moneyType);
      }
   }
}

