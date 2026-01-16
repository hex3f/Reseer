package com.robot.app.spt
{
   import com.robot.core.manager.MainManager;
   
   public class PioneerTaskModel
   {
      
      private static var _infoA:Array;
      
      private static var xmlClass:Class = PioneerTaskModel_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function PioneerTaskModel()
      {
         super();
      }
      
      public static function setup() : void
      {
         _infoA = new Array();
         makeListInfo();
      }
      
      public static function makeListInfo() : void
      {
         var _loc1_:XML = null;
         var _loc2_:SptInfo = null;
         var _loc3_:XMLList = xml.elements("spt");
         _infoA = new Array();
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = new SptInfo();
            _loc2_.id = uint(_loc1_.@id);
            _loc2_.description = _loc1_.@description;
            _loc2_.enterID = uint(_loc1_.@enterID);
            _loc2_.level = uint(_loc1_.@lel);
            _loc2_.onLine = Boolean(_loc1_.@online);
            _loc2_.seatID = uint(_loc1_.@seatID);
            _loc2_.status = uint(MainManager.actorInfo.bossAchievement[_loc2_.id - 1] > 0 ? 3 : 0);
            _loc2_.title = _loc1_.@title;
            _loc2_.fightCondition = _loc1_.@fightCondition;
            _infoA.push(_loc2_);
         }
      }
      
      public static function get infoA() : Array
      {
         if(!_infoA)
         {
            makeListInfo();
         }
         return _infoA;
      }
   }
}

