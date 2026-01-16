package com.robot.core.config.xml
{
   import flash.geom.Point;
   
   public class SuperMapXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var xmlClass:Class = SuperMapXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      setup();
      
      public function SuperMapXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         xmllist = xml.elements("maps");
      }
      
      public static function getWorldMapPos(param1:uint) : Point
      {
         var id:uint = param1;
         var xml:XML = null;
         var x:Number = NaN;
         var y:Number = NaN;
         var point:Point = null;
         xml = xmllist.(@id == id)[0];
         if(xml == null)
         {
            return null;
         }
         x = Number(xml.@x);
         y = Number(xml.@y);
         point = new Point(x,y);
         return point;
      }
      
      public static function getCurrentGalaxy(param1:uint) : uint
      {
         var id:uint = param1;
         var xml:XML = null;
         xml = xmllist.(@id == id)[0];
         if(xml == null)
         {
            return 0;
         }
         return xml.@galaxy;
      }
   }
}

