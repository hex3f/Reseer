package com.robot.core.config.xml
{
   public class DoodleXMLInfo
   {
      
      private static var _dataList:XMLList;
      
      private static var _url:String;
      
      private static var _preUrl:String;
      
      public function DoodleXMLInfo()
      {
         super();
      }
      
      public static function setup(param1:XML) : void
      {
         _url = param1.@url.toString();
         _preUrl = _url.replace(/swf\//,"prev/");
         _dataList = param1.elements("Item");
      }
      
      public static function getSwfURL(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         return _url + param1.toString() + ".swf";
      }
      
      public static function getPrevURL(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         return _preUrl + param1.toString() + ".swf";
      }
      
      public static function getName(param1:uint) : String
      {
         var id:uint = param1;
         return _dataList.(@ID == id.toString()).@name[0].toString();
      }
      
      public static function getPrice(param1:uint) : uint
      {
         var id:uint = param1;
         return uint(_dataList.(@ID == id.toString()).@Price[0].toString());
      }
      
      public static function getColor(param1:uint) : uint
      {
         var id:uint = param1;
         return uint(_dataList.(@ID == id.toString()).@Color[0]);
      }
      
      public static function getTexture(param1:uint) : uint
      {
         var id:uint = param1;
         return uint(_dataList.(@ID == id.toString()).@Texture[0]);
      }
      
      public static function getLength() : int
      {
         return _dataList.length();
      }
      
      public static function getList() : XMLList
      {
         return _dataList;
      }
   }
}

