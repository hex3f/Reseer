package com.robot.core.config
{
   public class UpdateConfig
   {
      
      private static var _xml:XML;
      
      public static var loadingArray:Array = [];
      
      public static var mapScrollArray:Array = [];
      
      public static var blueArray:Array = [];
      
      public static var greenArray:Array = [];
      
      public static var brotherArray:Array = [];
      
      public static var niusiArray:Array = [];
      
      public static var niuChangeMapArray:Array = [];
      
      public function UpdateConfig()
      {
         super();
      }
      
      public static function setup(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         _xml = param1;
         for each(_loc2_ in param1.loading.list)
         {
            loadingArray.push(_loc2_.@str);
         }
         for each(_loc2_ in param1.map.list)
         {
            mapScrollArray.push(_loc2_.@str);
         }
         for each(_loc2_ in param1.blue.list)
         {
            _loc3_ = String(_loc2_.@str);
            _loc3_ = _loc3_.replace(/\$/g,"\r");
            blueArray.push(_loc3_);
         }
         for each(_loc2_ in param1.green.list)
         {
            _loc3_ = String(_loc2_.@str);
            _loc3_ = _loc3_.replace(/\$/g,"\r");
            greenArray.push(_loc3_);
         }
         for each(_loc2_ in param1.brother.list)
         {
            brotherArray.push(_loc2_.@str);
         }
         for each(_loc2_ in param1.news.list)
         {
            niusiArray.push(_loc2_.@str);
         }
         for each(_loc2_ in param1.newsChangeMap.list)
         {
            niuChangeMapArray.push(_loc2_.@id);
         }
      }
   }
}

