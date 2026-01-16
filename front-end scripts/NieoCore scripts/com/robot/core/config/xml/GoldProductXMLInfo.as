package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class GoldProductXMLInfo
   {
      
      private static var _productMap:HashMap;
      
      private static var _itemMap:HashMap;
      
      private static var _xml:XML;
      
      private static var _xmllist:XMLList;
      
      private static var xmlClass:Class = GoldProductXMLInfo_xmlClass;
      
      setup();
      
      public function GoldProductXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _productMap = new HashMap();
         _itemMap = new HashMap();
         _xml = XML(new xmlClass());
         _xmllist = _xml.elements("item");
         for each(_loc1_ in _xmllist)
         {
            _productMap.add(_loc1_.@productID.toString(),_loc1_);
            _itemMap.add(_loc1_.@itemID.toString(),_loc1_);
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
      
      public static function getItemIDs(param1:uint) : Array
      {
         var proID:uint = param1;
         var xml:XML = null;
         var str:String = null;
         xml = _xmllist.(@productID == proID)[0];
         str = xml.@itemID;
         return str.split("|");
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
      
      public static function getNameByItemID(param1:uint) : String
      {
         var _loc2_:XML = _itemMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name;
         }
         return "";
      }
      
      public static function getPriceByProID(param1:uint) : uint
      {
         var proID:uint = param1;
         var xml:XML = null;
         xml = _xmllist.(@productID == proID)[0];
         if(xml == null)
         {
            return 0;
         }
         return xml.@price;
      }
      
      public static function getPriceByItemID(param1:uint) : uint
      {
         var id:uint = param1;
         var xml:XML = null;
         xml = _xmllist.(@itemID == id)[0];
         return xml.@price;
      }
      
      public static function getVipByProID(param1:uint) : Number
      {
         var proID:uint = param1;
         var xml:XML = null;
         xml = _xmllist.(@productID == proID)[0];
         return xml.@vip;
      }
      
      public static function getVipByItemID(param1:uint) : Number
      {
         var id:uint = param1;
         var xml:XML = null;
         xml = _xmllist.(@itemID == id)[0];
         return xml.@vip;
      }
   }
}

