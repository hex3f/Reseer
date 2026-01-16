package com.robot.core.config.xml
{
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.skeleton.ClothPreview;
   import org.taomee.ds.HashMap;
   
   public class ShotDisXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var _map:HashMap;
      
      private static var DEFAULT:uint;
      
      private static var xmlClass:Class = ShotDisXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      setup();
      
      public function ShotDisXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         DEFAULT = uint(xml.@defaultDis);
         _map = new HashMap();
         var _loc2_:XMLList = xml.elements("item");
         for each(_loc1_ in _loc2_)
         {
            _map.add(_loc1_.@id.toString(),_loc1_);
         }
      }
      
      public static function getDistance(param1:uint) : uint
      {
         var _loc2_:XML = _map.getValue(param1.toString());
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@dis);
         }
         return DEFAULT;
      }
      
      public static function getClothDistance(param1:Array) : uint
      {
         var _loc2_:Number = 0;
         for each(_loc2_ in param1)
         {
            if(ClothInfo.getItemInfo(_loc2_).type == ClothPreview.FLAG_HEAD)
            {
               break;
            }
         }
         return ItemXMLInfo.getShotDis(_loc2_);
      }
   }
}

