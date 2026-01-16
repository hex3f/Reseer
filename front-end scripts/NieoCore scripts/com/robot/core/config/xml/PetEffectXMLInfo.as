package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class PetEffectXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var _statXML:XMLList;
      
      private static var xmlClass:Class = PetEffectXMLInfo_xmlClass;
      
      setup();
      
      public function PetEffectXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var item:XML = null;
         var _id:uint = 0;
         _dataMap = new HashMap();
         var xl:XMLList = XML(new xmlClass()).elements("NewSeIdx");
         _statXML = xl.(@Stat == 1);
         for each(item in xl)
         {
            _id = uint(item.@ItemId);
            if(_id > 0)
            {
               _dataMap.add(_id,item);
            }
         }
      }
      
      public static function getItemIdForEffectId(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1) as XML;
         return uint(_loc2_.@ItemId);
      }
      
      public static function getDes(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1) as XML;
         return _loc2_.@Des;
      }
      
      public static function getEffect(param1:Number = -1) : String
      {
         var xmllist:XMLList = null;
         var xml:XML = null;
         var idx:Number = param1;
         xmllist = _statXML.(@Idx == idx);
         if(xmllist.length() > 0)
         {
            xml = xmllist[0];
            if(Boolean(xml))
            {
               return xml.@Desc;
            }
            return "";
         }
         return "";
      }
      
      public static function getDes2(param1:Number = -1) : String
      {
         var xmllist:XMLList = null;
         var xml:XML = null;
         var idx:Number = param1;
         xmllist = _statXML.(@Idx == idx);
         if(xmllist.length() > 0)
         {
            xml = xmllist[0];
            if(Boolean(xml))
            {
               return xml.@Desc2;
            }
            return "";
         }
         return "";
      }
   }
}

