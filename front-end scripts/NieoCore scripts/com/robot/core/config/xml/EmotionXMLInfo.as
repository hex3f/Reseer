package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   
   public class EmotionXMLInfo
   {
      
      private static var _hashMap:HashMap;
      
      private static var _xml:XML;
      
      private static var _xmllist:XMLList;
      
      private static var path:String;
      
      private static var xmlClass:Class = EmotionXMLInfo_xmlClass;
      
      setup();
      
      public function EmotionXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _xml = XML(new xmlClass());
         path = _xml.@path;
         _hashMap = new HashMap();
         _xmllist = _xml.emotion;
         for each(_loc1_ in _xmllist)
         {
            _hashMap.add(_loc1_.@shortcut.toString(),_loc1_);
         }
      }
      
      public static function getURL(param1:String) : String
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         if(!_loc2_)
         {
            throw new Error("不存在该表情快捷键");
         }
         return path + _loc2_.@id + ".swf";
      }
      
      public static function getDes(param1:String) : String
      {
         var _loc2_:XML = _hashMap.getValue(param1);
         if(!_loc2_)
         {
            throw new Error("不存在该表情快捷键");
         }
         return _loc2_.@des;
      }
   }
}

