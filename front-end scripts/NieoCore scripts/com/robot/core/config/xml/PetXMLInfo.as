package com.robot.core.config.xml
{
   import org.taomee.ds.HashMap;
   import org.taomee.utils.Utils;
   
   public class PetXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static var _xml:XML;
      
      private static var xmlClass:Class = PetXMLInfo_xmlClass;
      
      setup();
      
      public function PetXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         _dataMap = new HashMap();
         _xml = XML(new xmlClass());
         var _loc2_:XMLList = _xml.elements("Monster");
         for each(_loc1_ in _loc2_)
         {
            _dataMap.add(_loc1_.@ID.toString(),_loc1_);
         }
      }
      
      public static function getIdList() : Array
      {
         return _dataMap.getKeys();
      }
      
      public static function get dataList() : Array
      {
         return _dataMap.getValues();
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@DefName.toString();
         }
         return "";
      }
      
      public static function getType(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@Type.toString();
         }
         return "";
      }
      
      public static function getTypeList(param1:uint) : XMLList
      {
         var t:uint = param1;
         return _xml.(@Type == t);
      }
      
      public static function getClass(param1:uint) : Class
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(_loc2_ == null)
         {
            return null;
         }
         if(!_loc2_.hasOwnProperty("@className"))
         {
            return null;
         }
         var _loc3_:Class = Utils.getClass(_loc2_.@className.toString());
         if(Boolean(_loc3_))
         {
            return _loc3_;
         }
         return null;
      }
      
      public static function getEvolvFlag(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return _loc2_.@EvolvFlag;
      }
      
      public static function getEvolvingLv(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return _loc2_.@EvolvingLv;
      }
      
      public static function getSkillListForLv(param1:uint, param2:uint) : Array
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:XML = null;
         var _loc6_:Array = [];
         _loc3_ = _dataMap.getValue(param1);
         if(_loc3_ == null)
         {
            return _loc6_;
         }
         _loc4_ = _loc3_.elements("LearnableMoves")[0].elements("Move");
         for each(_loc5_ in _loc4_)
         {
            if(uint(_loc5_.@LearningLv) <= param2)
            {
               _loc6_.push(uint(_loc5_.@ID));
            }
         }
         return _loc6_;
      }
      
      public static function getTypeCN(param1:uint) : String
      {
         var _loc2_:uint = uint(getType(param1));
         return SkillXMLInfo.dict["key_" + _loc2_]["cn"];
      }
      
      public static function getTypeEN(param1:uint) : String
      {
         var _loc2_:uint = uint(getType(param1));
         return SkillXMLInfo.dict["key_" + _loc2_]["en"];
      }
      
      public static function fuseMaster(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return Boolean(uint(_loc2_.@FuseMaster));
      }
      
      public static function fuseSub(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return Boolean(uint(_loc2_.@FuseSub));
      }
      
      public static function getPetClass(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         return _loc2_.@PetClass;
      }
      
      public static function isLarge(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(!_loc2_.hasOwnProperty("@IsLarge"))
         {
            return false;
         }
         return Boolean(_loc2_.@IsLarge);
      }
      
      public static function getEvolvesTo(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@EvolvesTo")))
         {
            return uint(_loc2_.@EvolvesTo);
         }
         return 10000;
      }
      
      public static function getPetGender(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_.hasOwnProperty("@Gender")))
         {
            return uint(_loc2_.@Gender);
         }
         return 0;
      }
      
      public static function getPetGenderCN(param1:uint) : String
      {
         if(param1 == 1)
         {
            return "雄性";
         }
         if(param1 == 2)
         {
            return "雌性";
         }
         return "无性别";
      }
      
      public static function isFlyPet(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty("@isFlyPet")))
         {
            return Boolean(uint(_loc2_.@isFlyPet));
         }
         return false;
      }
      
      public static function isRidePet(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty("@isRidePet")))
         {
            return Boolean(uint(_loc2_.@isRidePet));
         }
         return false;
      }
      
      public static function flyPetSpeed(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty("@speed")))
         {
            return Number(_loc2_.@speed);
         }
         return 0;
      }
      
      public static function flyPetY(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty("@nameY")))
         {
            return Number(_loc2_.@nameY);
         }
         return 0;
      }
      
      public static function petScale(param1:uint) : Number
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty("@scale")))
         {
            return Number(_loc2_.@scale);
         }
         return 1;
      }
   }
}

