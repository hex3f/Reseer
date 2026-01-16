package com.robot.core.config
{
   import org.taomee.ds.HashMap;
   
   public class ServerConfig
   {
      
      private static var xml:XML;
      
      private static var hashMap:HashMap = new HashMap();
      
      public function ServerConfig()
      {
         super();
      }
      
      public static function setup(param1:XML) : void
      {
         var _loc2_:XML = null;
         xml = param1;
         var _loc3_:Number = 1;
         for each(_loc2_ in XML(xml.ServerList).descendants("list"))
         {
            hashMap.add(_loc3_,_loc2_.@name);
            _loc3_++;
         }
      }
      
      public static function getNameByID(param1:uint) : String
      {
         if(!hashMap.containsKey(param1))
         {
            return param1 + "服务器";
         }
         return hashMap.getValue(param1).toString();
      }
   }
}

