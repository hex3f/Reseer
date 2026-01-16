package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class TaskConditionXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = TaskConditionXMLInfo_xmlClass;
      
      setup();
      
      public function TaskConditionXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:* = 0;
         _dataMap = new HashMap();
         var _loc3_:XMLList = XML(new xmlClass()).elements("task");
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = uint(_loc1_.@id);
            _dataMap.add(_loc2_,_loc1_);
         }
      }
      
      public static function getConditionStep(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return _loc2_.@step;
      }
      
      public static function getConditionList(param1:uint) : Array
      {
         var _loc2_:XML = null;
         var _loc3_:Array = [];
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_))
         {
            for each(_loc2_ in _loc4_.condition)
            {
               _loc3_.push(new TaskConditionListInfo(_loc2_));
            }
         }
         return _loc3_;
      }
   }
}

