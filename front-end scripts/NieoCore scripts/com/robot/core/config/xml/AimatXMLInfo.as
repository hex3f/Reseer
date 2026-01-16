package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.ArrayUtil;
   
   public class AimatXMLInfo
   {
      
      private static var _dataList:Array;
      
      private static var _dataMap:HashMap;
      
      private static var xmlClass:Class = AimatXMLInfo_xmlClass;
      
      setup();
      
      public function AimatXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:Array = null;
         var _loc5_:* = 0;
         var _loc6_:Array = null;
         var _loc7_:* = null;
         _dataList = [];
         _dataMap = new HashMap();
         var _loc8_:XMLList = XML(new xmlClass()).elements("item");
         for each(_loc1_ in _loc8_)
         {
            _loc2_ = uint(_loc1_.@id);
            _loc3_ = uint(_loc1_.@tranID);
            _loc4_ = String(_loc1_.@cloth).split(",");
            _loc5_ = uint(_loc1_.@type);
            _loc6_ = [];
            for each(_loc7_ in _loc4_)
            {
               _loc6_.push(uint(_loc7_));
            }
            _dataList.push({
               "id":_loc2_,
               "cloth":_loc6_,
               "tranID":_loc3_,
               "type":_loc5_
            });
            _dataMap.add(_loc2_,_loc1_);
         }
      }
      
      public static function getType(param1:Array) : uint
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         for each(_loc2_ in _dataList)
         {
            _loc3_ = _loc2_.cloth;
            if(ArrayUtil.embody(param1,_loc3_))
            {
               if(Boolean(MainManager.actorModel))
               {
                  if(MainManager.actorModel.isTransform && _loc2_.tranID != 0)
                  {
                     return _loc2_.tranID;
                  }
                  return _loc2_.id;
               }
               return _loc2_.id;
            }
         }
         return _dataList[0].id;
      }
      
      public static function getTypeId(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@type);
         }
         return 0;
      }
      
      public static function getSoundStart(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@soundStart);
         }
         return 0;
      }
      
      public static function getIsStage(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@isState);
         }
         return 0;
      }
      
      public static function getSoundEnd(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@soundEnd);
         }
         return 0;
      }
      
      public static function getSpeed(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Number(_loc2_.@speed);
         }
         return 0;
      }
      
      public static function getCloths(param1:uint) : Array
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _dataList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_.cloth;
            }
         }
         return [];
      }
   }
}

