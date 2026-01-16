package org.taomee.utils
{
   import flash.utils.Dictionary;
   
   public class DictionaryUtil
   {
      
      public function DictionaryUtil()
      {
         super();
      }
      
      public static function getValues(param1:Dictionary) : Array
      {
         var _loc2_:Object = null;
         var _loc3_:Array = new Array();
         for each(_loc2_ in param1)
         {
            _loc3_.push(_loc2_);
         }
         return _loc3_;
      }
      
      public static function getKeys(param1:Dictionary) : Array
      {
         var _loc2_:Object = null;
         var _loc3_:Array = new Array();
         for(_loc2_ in param1)
         {
            _loc3_.push(_loc2_);
         }
         return _loc3_;
      }
   }
}

