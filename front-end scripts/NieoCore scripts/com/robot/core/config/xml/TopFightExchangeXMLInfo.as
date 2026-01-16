package com.robot.core.config.xml
{
   public class TopFightExchangeXMLInfo
   {
      
      private static var _xml:XML;
      
      private static var _xmllist:XMLList;
      
      private static var xmlClass:Class = TopFightExchangeXMLInfo_xmlClass;
      
      setup();
      
      public function TopFightExchangeXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         _xml = XML(new xmlClass());
         _xmllist = _xml.elements("Exchange");
      }
      
      public static function getExchangeList() : XMLList
      {
         return _xmllist;
      }
   }
}

