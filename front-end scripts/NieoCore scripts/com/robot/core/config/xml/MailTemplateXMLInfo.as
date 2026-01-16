package com.robot.core.config.xml
{
   import com.robot.core.config.ClientConfig;
   import flash.geom.Point;
   import org.taomee.ds.HashMap;
   import org.taomee.gemo.IntDimension;
   
   public class MailTemplateXMLInfo
   {
      
      private static var _hashMap:HashMap;
      
      private static var _xml:XML;
      
      private static var _xmllist:XMLList;
      
      private static var xmlClass:Class = MailTemplateXMLInfo_xmlClass;
      
      setup();
      
      public function MailTemplateXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _hashMap = new HashMap();
         _xml = XML(new xmlClass());
         _xmllist = _xml.elements("item");
         for each(_loc1_ in _xmllist)
         {
            _hashMap.add(uint(_loc1_.@id),_loc1_);
         }
      }
      
      public static function getTemplateSwf(param1:uint) : String
      {
         return ClientConfig.getMapPath(param1);
      }
      
      public static function getTitle(param1:uint) : String
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         if(_loc2_ == null)
         {
            return "";
         }
         return _loc2_;
      }
      
      public static function getTxtPos(param1:uint) : Point
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         return new Point(uint(_loc2_.@x),uint(_loc2_.@y));
      }
      
      public static function getTxtSize(param1:uint) : IntDimension
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         return new IntDimension(uint(_loc2_.@width),uint(_loc2_.@height));
      }
      
      public static function getCategoryList(param1:uint) : Array
      {
         var type:uint = param1;
         var l:XMLList = null;
         var array:Array = null;
         var i:XML = null;
         l = _xmllist.(@type == type.toString());
         array = [];
         for each(i in l)
         {
            array.push(i.@id);
         }
         return array;
      }
   }
}

