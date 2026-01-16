package com.robot.core.config.xml
{
   import com.robot.core.config.ClientConfig;
   import org.taomee.ds.HashMap;
   
   public class EggsXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xl:XMLList;
      
      private static var xmlClass:Class = EggsXMLInfo_xmlClass;
      
      setup();
      
      public function EggsXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:Array = null;
         _dataMap = new HashMap();
         xl = XML(new xmlClass()).elements("Egg");
         for each(_loc1_ in xl)
         {
            _dataMap.add(uint(_loc1_.@Id),_loc1_);
         }
         _loc2_ = _dataMap.getKeys();
      }
      
      public static function getIDList() : Array
      {
         return _dataMap.getKeys();
      }
      
      public static function getFatherID(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@MaleMon);
         }
         return 0;
      }
      
      public static function getMotherID(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@FemaleMon);
         }
         throw new Error("没有该蛋 ");
      }
      
      public static function getSpouseIDByMale(param1:uint) : uint
      {
         var _loc2_:XML = null;
         var _loc3_:Array = _dataMap.getValues();
         for each(_loc2_ in _loc3_)
         {
            if(uint(_loc2_.@MaleMon) == param1)
            {
               return uint(_loc2_.@FemaleMon);
            }
         }
         return 0;
      }
      
      public static function getSpouseIDByFeMale(param1:uint) : uint
      {
         var _loc2_:XML = null;
         var _loc3_:Array = _dataMap.getValues();
         for each(_loc2_ in _loc3_)
         {
            if(uint(_loc2_.@FemaleMon) == param1)
            {
               return uint(_loc2_.@MaleMon);
            }
         }
         return 0;
      }
      
      public static function getEggIconURL(param1:uint) : String
      {
         return ClientConfig.getResPath("egg/icon/" + param1 + ".swf");
      }
      
      public static function getEggEffectURL(param1:uint) : String
      {
         return ClientConfig.getResPath("egg/effect/" + param1 + ".swf");
      }
   }
}

