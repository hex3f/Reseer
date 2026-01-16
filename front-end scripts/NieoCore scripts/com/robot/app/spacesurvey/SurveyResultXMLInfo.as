package com.robot.app.spacesurvey
{
   public class SurveyResultXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var xmlClass:Class = SurveyResultXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function SurveyResultXMLInfo()
      {
         super();
      }
      
      public static function parseInfo() : void
      {
         if(xmllist == null)
         {
            xmllist = xml.descendants("star");
         }
      }
      
      public static function getIconName(param1:String) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(String(_loc2_.@name) == param1)
            {
               return _loc2_.@icon;
            }
         }
         return "";
      }
      
      public static function getIntrolInfo(param1:String) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(String(_loc2_.@name) == param1)
            {
               return _loc2_.@introl;
            }
         }
         return "";
      }
      
      public static function getSpaceName(param1:uint) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(uint(_loc2_.@id) == param1)
            {
               return _loc2_.@Name;
            }
         }
         return "";
      }
      
      public static function getSpaceID(param1:String) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(String(_loc2_.@name) == param1)
            {
               return String(_loc2_.@id);
            }
         }
         return "";
      }
      
      public static function getPetsByID(param1:uint) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(uint(_loc2_.@id) == param1)
            {
               return _loc2_.@pet;
            }
         }
         return "";
      }
      
      public static function getPetsByName(param1:String) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(String(_loc2_.@name) == param1)
            {
               return _loc2_.@pet;
            }
         }
         return "";
      }
      
      public static function getEnergysByID(param1:uint) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(uint(_loc2_.@id) == param1)
            {
               return _loc2_.@energy;
            }
         }
         return "";
      }
      
      public static function getEnergysByName(param1:String) : String
      {
         var _loc2_:XML = null;
         SurveyResultXMLInfo.parseInfo();
         for each(_loc2_ in xmllist)
         {
            if(String(_loc2_.@name) == param1)
            {
               return _loc2_.@energy;
            }
         }
         return "";
      }
   }
}

