package com.robot.core.config.xml
{
   import flash.utils.Dictionary;
   import org.taomee.utils.ArrayUtil;
   
   public class SpecialXMLInfo
   {
      
      private static var array:Array;
      
      private static var dict:Dictionary;
      
      private static var xmlClass:Class = SpecialXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      setup();
      
      public function SpecialXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:* = 0;
         var _loc3_:Array = null;
         array = [];
         dict = new Dictionary();
         var _loc4_:XMLList = xml.elements("item");
         for each(_loc1_ in _loc4_)
         {
            _loc2_ = uint(_loc1_.@id);
            _loc3_ = String(_loc1_.@cloths).split(",");
            array.push(_loc3_);
            dict[_loc3_] = _loc2_;
         }
      }
      
      public static function getSpecialID(param1:Array) : uint
      {
         var _loc2_:Array = null;
         var _loc3_:Number = 0;
         for each(_loc2_ in array)
         {
            if(ArrayUtil.arraysAreEqual(param1,_loc2_))
            {
               return uint(dict[_loc2_]);
            }
         }
         return _loc3_;
      }
   }
}

