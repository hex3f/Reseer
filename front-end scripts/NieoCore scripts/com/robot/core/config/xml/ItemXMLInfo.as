package com.robot.core.config.xml
{
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.manager.MainManager;
   import org.taomee.ds.HashMap;
   
   public class ItemXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var _speedMap:HashMap;
      
      private static var xml:XML;
      
      private static var xmlClass:Class = ItemXMLInfo_xmlClass;
      
      public function ItemXMLInfo()
      {
         super();
      }
      
      public static function parseInfo() : void
      {
         xml = XML(new xmlClass());
         var item:XML = null;
         _speedMap = new HashMap();
         xmllist = xml.descendants("Item");
         for each(item in xmllist)
         {
            if(String(item.@type) == "foot")
            {
               if(Boolean(xml.hasOwnProperty("@speed")))
               {
                  _speedMap.add(uint(item.@ID),MainManager.DfSpeed);
               }
               else
               {
                  _speedMap.add(uint(item.@ID),Number(item.@speed));
               }
            }
         }
         ClothInfo.parseInfo(xml.Cat.(@ID == 1)[0]);
         DoodleXMLInfo.setup(xml.Cat.(@ID == 2)[0]);
      }
      
      public static function getName(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Name;
      }
      
      public static function getPrice(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Price;
      }
      
      public static function getSellPrice(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@SellPrice;
      }
      
      public static function getRule(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml.hasOwnProperty("@Rule")))
         {
            return xml.@Rule;
         }
         return "";
      }
      
      public static function getType(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@type;
      }
      
      public static function getSwfURL(param1:uint, param2:uint = 1) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         var level:uint = param2;
         xml = xmllist.(@ID == id)[0];
         if(level == 0 || level == 1)
         {
            return XML(xml.parent()).@url + id.toString() + ".swf";
         }
         return XML(xml.parent()).@url + id.toString() + "_" + level + ".swf";
      }
      
      public static function getPrevURL(param1:uint, param2:uint = 1) : String
      {
         return getSwfURL(param1,param2).replace(/swf\//,"prev/");
      }
      
      public static function getIconURL(param1:uint, param2:uint = 1) : String
      {
         return getSwfURL(param1 >= 490001 && param1 < 500000 ? 400507 : (param1 == 400064 || param1 == 400065 ? 3 : param1),param2).replace(/swf\//,"icon/");
      }
      
      public static function getLifeTime(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@LifeTime;
      }
      
      public static function getHP(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@HP;
      }
      
      public static function getPP(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@PP;
      }
      
      public static function getSpeed(param1:Array) : Number
      {
         var _loc2_:uint = 0;
         var _loc3_:Number = NaN;
         for each(_loc2_ in param1)
         {
            _loc3_ = _speedMap.getValue(_loc2_) as Number;
            if(Boolean(_loc3_))
            {
               return _loc3_;
            }
         }
         return MainManager.DfSpeed;
      }
      
      public static function getFunID(param1:uint) : int
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(!xml.hasOwnProperty("@Fun"))
         {
            return 0;
         }
         return int(xml.@Fun);
      }
      
      public static function getFunIsCom(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(!xml.hasOwnProperty("@isCom"))
         {
            return false;
         }
         return Boolean(int(xml.@isCom));
      }
      
      public static function getDisabledDir(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(!xml.hasOwnProperty("@disabledDir"))
         {
            return false;
         }
         return Boolean(int(xml.@disabledDir));
      }
      
      public static function getDisabledStatus(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(!xml.hasOwnProperty("@disabledStatus"))
         {
            return false;
         }
         return Boolean(int(xml.@disabledStatus));
      }
      
      public static function getCatID(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.parent().@ID;
      }
      
      public static function getPlayID(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return uint(xml.@Play);
      }
      
      public static function getPower(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return uint(xml.@AddPower);
      }
      
      public static function getIQ(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return uint(xml.@AddIQ);
      }
      
      public static function getAiLevel(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return uint(xml.@UseAI);
      }
      
      public static function getVipOnly(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return Boolean(uint(xml.@VipOnly));
      }
      
      public static function getItemVipName(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml.hasOwnProperty("@VipName")))
         {
            return String(xml.@VipName);
         }
         return "";
      }
      
      public static function getIsConsume(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return uint(xml.@IsConsume);
      }
      
      public static function getIsSuper(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return Boolean(uint(xml.@VipOnly));
      }
      
      public static function getUseEnergy(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@UseEnergy;
      }
      
      public static function getIsFloor(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return Boolean(uint(xml.@floor));
      }
      
      public static function getSound(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml))
         {
            if(Boolean(xml.hasOwnProperty("@sound")))
            {
               return String(xml.@sound);
            }
         }
         return "";
      }
      
      public static function getShotDis(param1:uint) : uint
      {
         var xml:XML = null;
         var dis:uint = 0;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml))
         {
            if(uint(xml.@PkFireRange) == 0)
            {
               dis = 100;
            }
            else
            {
               dis = uint(xml.@PkFireRange);
            }
         }
         else
         {
            dis = 100;
         }
         return dis;
      }
      
      public static function getIsShowInPetBag(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml))
         {
            if(Boolean(xml.hasOwnProperty("@bShowPetBag")))
            {
               return Boolean(uint(xml.@bShowPetBag));
            }
         }
         return true;
      }
      
      public static function isSpecialItem(param1:uint) : Boolean
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(Boolean(xml) && Boolean(xml.hasOwnProperty("@isSpecial")))
         {
            return Boolean(uint(xml.@isSpecial));
         }
         return false;
      }
   }
}

