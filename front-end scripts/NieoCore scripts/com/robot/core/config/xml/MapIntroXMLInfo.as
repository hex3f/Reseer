package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class MapIntroXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = MapIntroXMLInfo_xmlClass;
      
      setup();
      
      public function MapIntroXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         var _loc2_:XMLList = XML(new xmlClass()).elements("map");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(uint(_loc1_.@id),_loc1_);
         }
      }
      
      public static function getType(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@type")))
         {
            return uint(_loc2_.@type);
         }
         return 0;
      }
      
      public static function getDifficulty(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@difficulty")))
         {
            return uint(_loc2_.@difficulty);
         }
         return 0;
      }
      
      public static function getLevel(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@level")))
         {
            return String(_loc2_.@level);
         }
         return "";
      }
      
      public static function getDes(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@des")))
         {
            return String(_loc2_.@des);
         }
         return "";
      }
      
      public static function getTasks(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("task")))
         {
            _loc2_ = String(_loc4_.task.@taskIDs);
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getSprites(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("sprite")))
         {
            _loc2_ = String(_loc4_.sprite.@petIDs);
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getMinerals(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("minerals")))
         {
            _loc2_ = String(_loc4_.minerals.@IDs);
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getGames(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("game")))
         {
            _loc2_ = String(_loc4_.game.@names);
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getNonos(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("nono")))
         {
            _loc2_ = String(_loc4_.nono.@names);
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getNewgoods(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_.hasOwnProperty("newgoods")))
         {
            _loc2_ = String(_loc4_.newgoods.@names);
            return _loc2_.split("|");
         }
         return [];
      }
   }
}

