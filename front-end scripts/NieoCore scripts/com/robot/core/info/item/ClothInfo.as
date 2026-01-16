package com.robot.core.info.item
{
   import flash.utils.Dictionary;
   
   public class ClothInfo
   {
      
      private static var dict:Dictionary;
      
      public static const DEFAULT_HEAD:uint = 100001;
      
      public static const DEFAULT_WAIST:uint = 100002;
      
      public static const DEFAULT_FOOT:uint = 100003;
      
      public function ClothInfo()
      {
         super();
      }
      
      public static function parseInfo(param1:XML) : void
      {
         var _loc2_:XML = null;
         dict = new Dictionary(true);
         var _loc3_:XMLList = param1.descendants("Item");
         for each(_loc2_ in _loc3_)
         {
            dict["item_" + _loc2_.@ID.toString()] = _loc2_;
         }
      }
      
      public static function getItemInfo(param1:int) : ClothData
      {
         if(!dict["item_" + param1.toString()])
         {
            throw new Error("没有找到对应的物品ID：" + param1);
         }
         return new ClothData(dict["item_" + param1.toString()]);
      }
   }
}

