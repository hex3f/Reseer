package com.robot.core.config.xml
{
   import flash.geom.Point;
   import org.taomee.ds.HashMap;
   
   public class OgreXMLInfo
   {
      
      private static var _ogreMap:HashMap;
      
      private static var _bossMap:HashMap;
      
      private static var _specialMap:HashMap;
      
      private static var xmlClass:Class = OgreXMLInfo_xmlClass;
      
      setup();
      
      public function OgreXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:XMLList = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:Array = null;
         var _loc13_:int = 0;
         var _loc14_:Array = null;
         _ogreMap = new HashMap();
         var _loc15_:XMLList = XML(new xmlClass()).elements("ogre")[0].elements("item");
         for each(_loc1_ in _loc15_)
         {
            _loc6_ = _loc1_.@pList.toString();
            _loc7_ = _loc6_.split("|");
            _loc8_ = int(_loc7_.length);
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc10_ = _loc7_[_loc9_].split(",");
               _loc7_[_loc9_] = new Point(_loc10_[0],_loc10_[1]);
               _loc9_++;
            }
            _ogreMap.add(uint(_loc1_.@id),_loc7_);
         }
         _bossMap = new HashMap();
         _loc2_ = XML(new xmlClass()).elements("boss")[0].elements("item");
         for each(_loc3_ in _loc2_)
         {
            _bossMap.add(uint(_loc3_.@id),_loc3_);
         }
         _specialMap = new HashMap();
         _loc4_ = XML(new xmlClass()).elements("special")[0].elements("item");
         for each(_loc5_ in _loc4_)
         {
            _loc11_ = _loc5_.@pList.toString();
            _loc12_ = _loc11_.split("|");
            _loc13_ = int(_loc12_.length);
            _loc9_ = 0;
            while(_loc9_ < _loc13_)
            {
               _loc14_ = _loc12_[_loc9_].split(",");
               _loc12_[_loc9_] = new Point(_loc14_[0],_loc14_[1]);
               _loc9_++;
            }
            _specialMap.add(uint(_loc5_.@id),_loc12_);
         }
      }
      
      public static function getOgreList(param1:uint) : Array
      {
         return _ogreMap.getValue(param1);
      }
      
      public static function getBossList(param1:uint, param2:uint) : Array
      {
         var mapID:uint = param1;
         var region:uint = param2;
         var str:String = null;
         var arr:Array = null;
         var len:int = 0;
         var k:int = 0;
         var parr:Array = null;
         var xml:XML = _bossMap.getValue(mapID);
         if(Boolean(xml))
         {
            xml = xml.elements("region").(@id == region)[0];
            if(Boolean(xml))
            {
               str = xml.@pList.toString();
               arr = str.split("|");
               len = int(arr.length);
               k = 0;
               while(k < len)
               {
                  parr = arr[k].split(",");
                  arr[k] = new Point(parr[0],parr[1]);
                  k++;
               }
               return arr;
            }
         }
         return null;
      }
      
      public static function getSpecialList(param1:uint) : Array
      {
         return _specialMap.getValue(param1);
      }
   }
}

