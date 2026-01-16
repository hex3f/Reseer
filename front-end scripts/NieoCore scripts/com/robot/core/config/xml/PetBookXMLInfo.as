package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class PetBookXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = PetBookXMLInfo_xmlClass;
      
      setup();
      
      public function PetBookXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         var _loc2_:XMLList = XML(new xmlClass()).elements("Monster");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(_loc1_.@ID.toString(),_loc1_);
         }
      }
      
      public static function get dataList() : Array
      {
         return _dataMap.getValues();
      }
      
      public static function getPetXML(param1:uint) : XML
      {
         return _dataMap.getValue(param1);
      }
      
      public static function getName(param1:uint) : String
      {
         return getPetXML(param1).@DefName.toString();
      }
      
      public static function getType(param1:uint) : String
      {
         return getPetXML(param1).@Type.toString();
      }
      
      public static function getHeight(param1:uint) : String
      {
         return getPetXML(param1).@Height.toString();
      }
      
      public static function getWeight(param1:uint) : String
      {
         return getPetXML(param1).@Weight.toString();
      }
      
      public static function getFoundin(param1:uint) : String
      {
         return getPetXML(param1).@Foundin.toString();
      }
      
      public static function getFeatures(param1:uint) : String
      {
         return getPetXML(param1).@Features.toString();
      }
      
      public static function hasSound(param1:uint) : Boolean
      {
         var _loc2_:XML = getPetXML(param1) as XML;
         if(Boolean(_loc2_.hasOwnProperty("@hasSound")))
         {
            return Boolean(_loc2_.@hasSound);
         }
         return false;
      }
      
      public static function food(param1:uint) : String
      {
         return getPetXML(param1).@Food.toString();
      }
   }
}

