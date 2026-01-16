package com.robot.core.config.xml
{
   public class EvolveXMLInfo
   {
      
      private static var xml:XML;
      
      private static var xmlcls:Class = EvolveXMLInfo_xmlcls;
      
      public function EvolveXMLInfo()
      {
         super();
      }
      
      private static function getXMLData() : XML
      {
         if(xml == null)
         {
            xml = new XML(new xmlcls());
         }
         return xml;
      }
      
      public static function getEvolveID() : Array
      {
         var _loc1_:XML = null;
         var _loc2_:Array = new Array();
         var _loc3_:XMLList = EvolveXMLInfo.getXMLData().elements("Evolve");
         for each(_loc1_ in _loc3_)
         {
            _loc2_.push(Number(_loc1_.@ID));
         }
         if(_loc2_.length <= 0)
         {
            return null;
         }
         return _loc2_;
      }
      
      public static function getMonToIDs(param1:Number) : Array
      {
         var _loc2_:XML = null;
         var _loc3_:XMLList = null;
         var _loc4_:XML = null;
         var _loc5_:Object = null;
         var _loc6_:Array = new Array();
         var _loc7_:XMLList = EvolveXMLInfo.getXMLData().elements("Evolve");
         for each(_loc2_ in _loc7_)
         {
            if(Number(_loc2_.@ID) == param1)
            {
               _loc3_ = _loc2_.elements("Branch");
               for each(_loc4_ in _loc3_)
               {
                  _loc5_ = new Object();
                  _loc5_.MonTo = Number(_loc4_.@MonTo);
                  _loc5_.EvolvItem = Number(_loc4_.@EvolvItem);
                  _loc5_.EvolvItemCount = Number(_loc4_.@EvolvItemCount);
                  _loc6_.push(_loc5_);
               }
            }
         }
         if(_loc6_.length <= 0)
         {
            return null;
         }
         return _loc6_;
      }
      
      public static function getEvolveItem(param1:Number, param2:Number) : Number
      {
         return 0;
      }
      
      public static function getEvolveCount(param1:Number, param2:Number) : Number
      {
         return 0;
      }
   }
}

