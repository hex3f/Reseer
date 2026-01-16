package com.robot.app.fightLevel
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserInfoManager;
   
   public class FightLevelModel
   {
      
      private static var info:Array;
      
      private static var currentBossId:Array;
      
      private static var curLevel:uint;
      
      private static var nextBossId:Array;
      
      private static var xmlClass:Class = FightLevelModel_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      private static const _maxLevel:uint = 80;
      
      private static var b1:Boolean = false;
      
      public function FightLevelModel()
      {
         super();
      }
      
      public static function setUp() : void
      {
         info = new Array();
         UserInfoManager.upDateMoreInfo(MainManager.actorInfo,upDatahandler);
      }
      
      private static function upDatahandler() : void
      {
         var _loc1_:Object = null;
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         while(_loc3_ < xml.level.length())
         {
            _loc1_ = new Object();
            _loc1_.id = xml.level[_loc3_].@id;
            _loc1_.itemId = xml.level[_loc3_].@itemId;
            if(MainManager.actorInfo.maxStage == 0)
            {
               _loc1_.isOpen = false;
            }
            else
            {
               if(MainManager.actorInfo.maxStage <= 10)
               {
                  _loc2_ = 1;
               }
               else if(MainManager.actorInfo.maxStage == _maxLevel)
               {
                  _loc2_ = uint(_maxLevel / 10);
               }
               else if(MainManager.actorInfo.maxStage % 10 == 0)
               {
                  _loc2_ = uint(MainManager.actorInfo.maxStage / 10);
               }
               else
               {
                  _loc2_ = uint(uint(MainManager.actorInfo.maxStage / 10) + 1);
               }
               if(uint(_loc1_.id) <= _loc2_)
               {
                  _loc1_.isOpen = true;
               }
               else
               {
                  _loc1_.isOpen = false;
               }
            }
            info.push(_loc1_);
            _loc3_++;
         }
         FightChoiceController.show();
      }
      
      public static function get list() : Array
      {
         return info;
      }
      
      public static function set setBossId(param1:Array) : void
      {
         currentBossId = param1;
      }
      
      public static function get getBossId() : Array
      {
         return currentBossId;
      }
      
      public static function set setCurLevel(param1:uint) : void
      {
         curLevel = param1;
      }
      
      public static function get getCurLevel() : uint
      {
         return curLevel;
      }
      
      public static function set setNextBossId(param1:Array) : void
      {
         nextBossId = param1;
      }
      
      public static function get getNextBossId() : Array
      {
         return nextBossId;
      }
      
      public static function get maxLevel() : uint
      {
         return _maxLevel;
      }
   }
}

