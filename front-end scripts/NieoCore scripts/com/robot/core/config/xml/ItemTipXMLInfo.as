package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class ItemTipXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var _map:HashMap;
      
      private static var xmlClass:Class = ItemTipXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      setup();
      
      public function ItemTipXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _map = new HashMap();
         xmllist = xml.descendants("item");
         for each(_loc1_ in xmllist)
         {
            _map.add(uint(_loc1_.@id),_loc1_);
         }
      }
      
      public static function getItemDes(param1:uint) : String
      {
         var _loc2_:XML = _map.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@des;
         }
         return "";
      }
      
      public static function getItemColor(param1:uint) : String
      {
         var _loc2_:XML = _map.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@color;
         }
         return "#ffffff";
      }
      
      public static function getPetDes(param1:uint, param2:uint = 1) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         var level:uint = param2;
         var str:String = null;
         var _x:XML = null;
         var i:XML = null;
         if(level == 0)
         {
            level = 1;
         }
         xml = _map.getValue(id);
         if(Boolean(xml))
         {
            str = "";
            _x = xml.pet.level.(@value == level.toString())[0];
            if(_x == null)
            {
               return "";
            }
            for each(i in _x.list)
            {
               str += i.@des + "\r";
            }
            return str;
         }
         return "";
      }
      
      public static function getTeamPKDes(param1:uint, param2:uint = 1) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         var level:uint = param2;
         var str:String = null;
         var _x:XML = null;
         var i:XML = null;
         if(level == 0)
         {
            level = 1;
         }
         xml = _map.getValue(id);
         if(Boolean(xml))
         {
            str = "";
            _x = xml.teamPK.level.(@value == level.toString())[0];
            if(_x == null)
            {
               return "";
            }
            for each(i in _x.list)
            {
               str += i.@des + "\r";
            }
            return str;
         }
         return "";
      }
   }
}

