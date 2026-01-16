package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import org.taomee.ds.HashMap;
   
   public class NpcXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xl:XMLList;
      
      private static var xmlClass:Class = NpcXMLInfo_xmlClass;
      
      setup();
      
      public function NpcXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         xl = XML(new xmlClass()).elements("npc");
         for each(_loc1_ in xl)
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
      
      public static function getType(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@type);
         }
         throw new Error("没有该NPC");
      }
      
      public static function getNpcXmlByMap(param1:uint) : XMLList
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         xmlList = xl.(@mapID == id.toString());
         return xmlList;
      }
      
      public static function getStartIDs(param1:uint) : Array
      {
         var array:Array = null;
         var id:uint = param1;
         var str:String = null;
         array = null;
         var i1:int = 0;
         str = xl.(@id == id).@startTask.toString();
         if(str == "")
         {
            return [];
         }
         array = str.split("|");
         array.forEach(function(param1:*, param2:int, param3:Array):void
         {
            array[param2] = uint(param1);
         });
         if(MainManager.checkIsNovice())
         {
            i1 = 0;
            while(i1 < array.length)
            {
               if(array[i1] == 1 || array[i1] == 2 || array[i1] == 3 || array[i1] == 4)
               {
                  array.splice(i1,1);
                  i1--;
               }
               i1++;
            }
            if(array.length == 0)
            {
               array = [];
            }
         }
         return array;
      }
      
      public static function getEndIDs(param1:uint) : Array
      {
         var array:Array = null;
         var id:uint = param1;
         var str:String = null;
         array = null;
         str = xl.(@id == id).@endTask.toString();
         if(str == "")
         {
            return [];
         }
         array = str.split("|");
         array.forEach(function(param1:*, param2:int, param3:Array):void
         {
            array[param2] = uint(param1);
         });
         return array;
      }
      
      public static function getNpcProIDs(param1:uint) : Array
      {
         var array:Array = null;
         var id:uint = param1;
         var str:String = null;
         array = null;
         str = xl.(@id == id).@proTask.toString();
         if(str == "")
         {
            return [];
         }
         array = str.split("|");
         array.forEach(function(param1:*, param2:int, param3:Array):void
         {
            array[param2] = uint(param1);
         });
         return array;
      }
   }
}

