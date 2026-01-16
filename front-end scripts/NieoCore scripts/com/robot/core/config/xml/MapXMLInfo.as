package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import flash.geom.Point;
   import org.taomee.ds.HashMap;
   
   public class MapXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = MapXMLInfo_xmlClass;
      
      setup();
      
      public function MapXMLInfo()
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
      
      public static function getIDList() : Array
      {
         return _dataMap.getKeys();
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@name);
         }
         return "";
      }
      
      public static function getDefaultPos(param1:uint) : Point
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return new Point(int(_loc2_.@x),int(_loc2_.@y));
         }
         return MainManager.getStageCenterPoint();
      }
      
      public static function getRoomDefaultFloPos(param1:uint) : Point
      {
         if(param1 < MapManager.ID_MAX)
         {
            return MainManager.getStageCenterPoint();
         }
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return new Point(int(_loc2_.@fx),int(_loc2_.@fy));
         }
         return MainManager.getStageCenterPoint();
      }
      
      public static function getRoomDefaultWapPos(param1:uint) : Point
      {
         if(param1 < MapManager.ID_MAX)
         {
            return MainManager.getStageCenterPoint();
         }
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return new Point(int(_loc2_.@wx),int(_loc2_.@wy));
         }
         return MainManager.getStageCenterPoint();
      }
      
      public static function getHeadPos(param1:uint) : Point
      {
         if(param1 < MapManager.ID_MAX)
         {
            return MainManager.getStageCenterPoint();
         }
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return new Point(int(_loc2_.@hx),int(_loc2_.@hy));
         }
         return MainManager.getStageCenterPoint();
      }
      
      public static function getIsLocal(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(!_loc2_)
         {
            return false;
         }
         if(Boolean(_loc2_.hasOwnProperty("@isLocal")))
         {
            return Boolean(uint(_loc2_.@isLocal));
         }
         return false;
      }
      
      public static function getBgSoundIdByMapId(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(!_loc2_)
         {
            return "";
         }
         if(Boolean(_loc2_.hasOwnProperty("@sound")))
         {
            return _loc2_.@sound;
         }
         return "";
      }
      
      public static function getNpcIdByMapId(param1:uint) : Array
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(!_loc2_)
         {
            return [];
         }
         if(Boolean(_loc2_.hasOwnProperty("@npc")))
         {
            return _loc2_.@npc.split("|");
         }
         return [];
      }
   }
}

