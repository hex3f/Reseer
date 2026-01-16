package com.robot.core.config.xml
{
   public class AchieveXMLInfo
   {
      
      private static var xmlClass:Class = AchieveXMLInfo_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function AchieveXMLInfo()
      {
         super();
      }
      
      public static function getTypeName(param1:uint) : String
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("type");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@ID == param1.toString())
            {
               _loc2_ = _loc3_.@Desc;
               break;
            }
         }
         return _loc2_;
      }
      
      public static function getBranchIDs(param1:uint) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:uint = uint(xml.type[param1].Branches.length());
         var _loc6_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc4_ = uint(xml.type[param1].Branches[_loc2_].Branch.length());
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               _loc6_.push(uint(xml.type[param1].Branches[_loc2_].Branch[_loc3_].@ID));
               _loc3_++;
            }
            _loc2_++;
         }
         return _loc6_;
      }
      
      public static function getBranchByID(param1:uint) : XML
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("Branch");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@ID == param1.toString())
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         return setIconID(_loc2_);
      }
      
      public static function getIsShowPro(param1:uint) : uint
      {
         var _loc2_:XML = null;
         var _loc3_:XMLList = xml.descendants("Branch");
         var _loc4_:uint = 0;
         for each(_loc2_ in _loc3_)
         {
            if(_loc2_.@ID == param1.toString())
            {
               if(_loc2_.@isShowPro == "1")
               {
                  _loc4_ = 1;
                  break;
               }
            }
         }
         return _loc4_;
      }
      
      public static function getRule(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:XML = getBranchByID(param1);
         if(null == _loc5_)
         {
            return null;
         }
         var _loc6_:XMLList = _loc5_.descendants("Rule");
         for each(_loc4_ in _loc6_)
         {
            if(_loc4_.@ID == param2.toString())
            {
               _loc3_ = _loc4_;
               break;
            }
         }
         return setIconID(_loc3_);
      }
      
      public static function getOriginalTitle(param1:uint) : String
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("Rule");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@SpeNameBonus == param1.toString())
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ == null)
         {
            return "无称号";
         }
         return _loc2_.@title;
      }
      
      public static function getTitle(param1:uint) : String
      {
         var _loc2_:String = null;
         _loc2_ = getOriginalTitle(param1);
         return _loc2_.replace("|","");
      }
      
      public static function getTitleIconId(param1:uint) : int
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("Rule");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@SpeNameBonus == param1.toString())
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ == null || !_loc2_.hasOwnProperty("@proicon"))
         {
            return 0;
         }
         return int(_loc2_.@proicon);
      }
      
      public static function getTitleColor(param1:uint) : int
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("Rule");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@SpeNameBonus == param1.toString())
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ == null || !_loc2_.hasOwnProperty("@titleColor"))
         {
            return 0;
         }
         return _loc2_.@titleColor;
      }
      
      public static function isAbilityTitle(param1:uint) : Boolean
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XMLList = xml.descendants("Rule");
         for each(_loc3_ in _loc4_)
         {
            if(_loc3_.@SpeNameBonus == param1.toString() && int(_loc3_.@AbilityTitle) > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getAbilityTitles() : Array
      {
         var _loc1_:XML = null;
         var _loc2_:XML = null;
         var _loc3_:XMLList = xml.descendants("Rule");
         var _loc4_:Array = [];
         for each(_loc2_ in _loc3_)
         {
            if(int(_loc2_.@SpeNameBonus) > 0 && int(_loc2_.@AbilityTitle) > 0)
            {
               _loc4_.push(int(_loc2_.@SpeNameBonus));
            }
         }
         return _loc4_;
      }
      
      private static function setIconID(param1:XML) : XML
      {
         var _loc2_:String = null;
         if(param1 == null)
         {
            return param1;
         }
         var _loc3_:String = param1.@AchievementPoint;
         switch(_loc3_)
         {
            case "5":
               _loc2_ = "8";
               break;
            case "10":
               _loc2_ = "1";
               break;
            case "15":
               _loc2_ = "2";
               break;
            case "30":
               _loc2_ = "3";
               break;
            case "20":
               _loc2_ = "4";
               break;
            case "25":
               _loc2_ = "7";
               break;
            case "40":
               _loc2_ = "5";
               break;
            case "50":
               _loc2_ = "6";
               break;
            case "35":
               _loc2_ = "9";
         }
         param1.@icon = _loc2_;
         return param1;
      }
   }
}

