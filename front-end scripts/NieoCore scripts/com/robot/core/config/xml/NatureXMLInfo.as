package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class NatureXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = NatureXMLInfo_xmlClass;
      
      setup();
      
      public function NatureXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         var _loc2_:XMLList = XML(new xmlClass()).elements("item");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(uint(_loc1_.@id),_loc1_);
         }
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
      
      public static function getAttack(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@m_attack);
         }
         return -1;
      }
      
      public static function getDefence(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@m_defence);
         }
         return -1;
      }
      
      public static function getSpAttack(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@m_SA);
         }
         return -1;
      }
      
      public static function getSpDefence(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@m_SD);
         }
         return -1;
      }
      
      public static function getSpeed(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@m_speed);
         }
         return -1;
      }
      
      public static function getDesc(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@desc);
         }
         return "";
      }
   }
}

