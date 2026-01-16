package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class GalaxyXMLInfo
   {
      
      private static var _hashMap:HashMap;
      
      private static var _xml:XML;
      
      private static var _xmllist:XMLList;
      
      private static var xmlClass:Class = GalaxyXMLInfo_xmlClass;
      
      setup();
      
      public function GalaxyXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _hashMap = new HashMap();
         _xml = XML(new xmlClass());
         _xmllist = _xml.elements("galaxy");
         for each(_loc1_ in _xmllist)
         {
            _hashMap.add(uint(_loc1_.@id),_loc1_);
         }
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name;
         }
         return "";
      }
   }
}

