package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class TimePasswordXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var _xml:XML;
      
      private static var xmlClass:Class = TimePasswordXMLInfo_xmlClass;
      
      setup();
      
      public function TimePasswordXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         _xml = XML(new xmlClass());
         var _loc2_:XMLList = _xml.elements("item");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(_loc1_.@id.toString(),_loc1_);
         }
      }
      
      public static function getIDList() : Array
      {
         return _dataMap.getKeys();
      }
   }
}

