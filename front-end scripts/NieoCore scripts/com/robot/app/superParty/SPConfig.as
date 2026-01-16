package com.robot.app.superParty
{
   public class SPConfig
   {
      
      private static var _infoA:Array;
      
      private static var xmlClass:Class = SPConfig_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function SPConfig()
      {
         super();
      }
      
      public static function makeInfo() : void
      {
         var _loc1_:XML = null;
         var _loc2_:SuperPartyInfo = null;
         _infoA = new Array();
         var _loc3_:XMLList = xml.elements("SP");
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = new SuperPartyInfo();
            if(_loc1_.@games == "")
            {
               _loc2_.games = new Array();
            }
            else
            {
               _loc2_.games = String(_loc1_.@games).split("|");
            }
            _loc2_.mapID = uint(_loc1_.@mapID);
            if(_loc1_.@oreIDs == "")
            {
               _loc2_.oreIDs = new Array();
            }
            else
            {
               _loc2_.oreIDs = String(_loc1_.@oreIDs).split("|");
            }
            if(_loc1_.@petIDs != "")
            {
               _loc2_.petIDs = String(_loc1_.@petIDs).split("|");
            }
            else
            {
               _loc2_.petIDs = new Array();
            }
            _infoA.push(_loc2_);
         }
      }
      
      public static function get infos() : Array
      {
         if(!_infoA)
         {
            makeInfo();
         }
         return _infoA;
      }
      
      public static function get title() : String
      {
         var _loc1_:XML = null;
         var _loc2_:XMLList = xml.elements("title");
         var _loc3_:String = "";
         for each(_loc1_ in _loc2_)
         {
            _loc3_ += _loc1_.@msg;
         }
         return _loc3_;
      }
   }
}

