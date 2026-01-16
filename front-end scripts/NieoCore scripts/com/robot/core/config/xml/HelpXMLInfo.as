package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import flash.geom.Point;
   import org.taomee.ds.HashMap;
   
   public class HelpXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xl:XMLList;
      
      private static var xmlClass:Class = HelpXMLInfo_xmlClass;
      
      private static const PRO:String = "pro";
      
      setup();
      
      public function HelpXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         xl = new XML(new xmlClass()).elements("help");
         for each(_loc1_ in xl)
         {
            _dataMap.add(uint(_loc1_.@id),_loc1_);
         }
      }
      
      public static function getIdList() : Array
      {
         return _dataMap.getKeys();
      }
      
      public static function getType(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return uint(_loc2_.@type);
      }
      
      public static function getArrowPoint(param1:uint) : Point
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return new Point(_loc2_.@arrowX,_loc2_.@arrowY);
      }
      
      public static function getMapId(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return new uint(_loc2_.@mapId);
      }
      
      public static function getIsBack(param1:uint) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:XML = _dataMap.getValue(param1);
         if(_loc3_.@isBack == "1")
         {
            _loc2_ = true;
         }
         else
         {
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      public static function getItemAry(param1:uint) : Array
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         var _loc3_:uint = uint(_loc2_.elements(PRO).length());
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_.push(new Array(_loc2_.elements(PRO)[_loc5_].@item,_loc2_.elements(PRO)[_loc5_].@clickTo));
            _loc5_++;
         }
         return _loc4_;
      }
      
      public static function getComment(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         var _loc3_:String = String(_loc2_.des);
         _loc3_ = _loc3_.replace(/#nick/g,MainManager.actorInfo.nick);
         return _loc3_.replace("$","\r");
      }
   }
}

