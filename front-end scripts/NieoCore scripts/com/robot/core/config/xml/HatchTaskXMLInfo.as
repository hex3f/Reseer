package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class HatchTaskXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static const PRO:String = "pro";
      
      private static var xmlClass:Class = HatchTaskXMLInfo_xmlClass;
      
      setup();
      
      public function HatchTaskXMLInfo()
      {
         super();
      }
      
      public static function get dataMap() : HashMap
      {
         return _dataMap;
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:* = 0;
         _dataMap = new HashMap();
         var _loc3_:XMLList = XML(new xmlClass()).elements("task");
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = uint(_loc1_.@ID);
            _dataMap.add(_loc2_,_loc1_);
         }
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name.toString();
         }
         return "";
      }
      
      public static function getTaskProCount(param1:uint) : int
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.elements(PRO).length();
         }
         return 0;
      }
      
      public static function getTaskMapList(param1:uint) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:Number = 0;
         while(_loc3_ < getTaskProCount(param1))
         {
            _loc2_.push(getProMap(param1,_loc3_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function isDir(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@isDir));
         }
         return false;
      }
      
      public static function isMat(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@isMat));
         }
         return false;
      }
      
      public static function getProName(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@name.toString();
         }
         return "";
      }
      
      public static function getProMCName(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@mc.toString();
         }
         return "";
      }
      
      public static function getProMap(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@map;
         }
         return 0;
      }
      
      public static function getMapPro(param1:uint, param2:uint) : Array
      {
         var _loc3_:XMLList = null;
         var _loc4_:Number = 0;
         var _loc5_:Array = [];
         var _loc6_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc6_))
         {
            _loc3_ = _loc6_.elements(PRO);
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length())
            {
               if(_loc3_[_loc4_].@map == param2)
               {
                  _loc5_.push(_loc4_);
               }
               _loc4_++;
            }
         }
         return _loc5_;
      }
      
      public static function getProParent(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:Boolean = false;
         if(param2 == 0)
         {
            return true;
         }
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_))
         {
            return Boolean(_loc4_.elements(PRO)[param2 - 1].@isMat);
         }
         return false;
      }
      
      public static function getMapSoulBeadList(param1:uint) : Array
      {
         var _loc2_:XML = null;
         var _loc3_:* = 0;
         var _loc4_:Array = [];
         var _loc5_:XML = XML(new xmlClass());
         var _loc6_:XMLList = _loc5_..pro;
         for each(_loc2_ in _loc6_)
         {
            if(_loc2_.@map == param1)
            {
               _loc3_ = uint(_loc2_.parent().@ID);
               _loc4_.push(_loc3_);
            }
         }
         return _loc4_;
      }
      
      public static function getProDes(param1:uint, param2:uint) : String
      {
         var _loc3_:* = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_))
         {
            return String(_loc4_.elements(PRO)[param2].@des);
         }
         return "";
      }
   }
}

