package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class MovesLangXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = MovesLangXMLInfo_xmlClass;
      
      setup();
      
      public function MovesLangXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         var _loc2_:XMLList = XML(new xmlClass()).elements("moves");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(uint(_loc1_.@id),_loc1_.elements("lang"));
         }
      }
      
      public static function getRandomLang(param1:uint) : String
      {
         var _loc2_:XML = null;
         var _loc3_:XMLList = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            _loc2_ = _loc3_[int(_loc3_.length() * Math.random())];
            return _loc2_.toString();
         }
         return "";
      }
   }
}

