package com.robot.core.config.xml
{
   import flash.utils.Dictionary;
   
   public class SkillXMLInfo
   {
      
      private static var xmllist:XMLList;
      
      private static var sideEffectXMLList:XMLList;
      
      private static var SKILL_XML:XML;
      
      private static var xmlClass:Class = SkillXMLInfo_xmlClass;
      
      private static var categoryNames:Dictionary = new Dictionary();
      
      public static var dict:Dictionary = new Dictionary();
      
      parseInfo();
      
      public function SkillXMLInfo()
      {
         super();
      }
      
      private static function parseInfo() : void
      {
         SKILL_XML = XML(new xmlClass());
         xmllist = SKILL_XML.descendants("Move");
         sideEffectXMLList = SKILL_XML.descendants("SideEffect");
         dict["key_1"] = {
            "cn":"草",
            "en":"grass"
         };
         dict["key_2"] = {
            "cn":"水",
            "en":"water"
         };
         dict["key_3"] = {
            "cn":"火",
            "en":"fire"
         };
         dict["key_4"] = {
            "cn":"飞行",
            "en":"fly"
         };
         dict["key_5"] = {
            "cn":"电",
            "en":"bolt"
         };
         dict["key_6"] = {
            "cn":"机械",
            "en":"steel"
         };
         dict["key_7"] = {
            "cn":"地面",
            "en":"ground"
         };
         dict["key_8"] = {
            "cn":"普通",
            "en":"normal"
         };
         dict["key_9"] = {
            "cn":"冰",
            "en":"ice"
         };
         dict["key_10"] = {
            "cn":"超能",
            "en":"super"
         };
         dict["key_11"] = {
            "cn":"战斗",
            "en":"fight"
         };
         dict["key_12"] = {
            "cn":"光",
            "en":"light"
         };
         dict["key_13"] = {
            "cn":"暗影",
            "en":"dark"
         };
         dict["key_14"] = {
            "cn":"神秘",
            "en":"secrect"
         };
         dict["key_15"] = {
            "cn":"龙",
            "en":"dragon"
         };
         dict["key_16"] = {
            "cn":"圣灵",
            "en":"saint"
         };
         dict["key_17"] = {
            "cn":"次元",
            "en":"dimension"
         };
         dict["key_18"] = {
            "cn":"远古",
            "en":"ancient"
         };
         dict["key_19"] = {
            "cn":"邪灵",
            "en":"demon"
         };
         dict["key_20"] = {
            "cn":"自然",
            "en":"nature"
         };
         dict["key_21"] = {
            "cn":"草 超能",
            "en":"grass_psychic"
         };
         dict["key_22"] = {
            "cn":"草 战斗",
            "en":"grass_fight"
         };
         dict["key_23"] = {
            "cn":"草 暗影",
            "en":"grass_dark"
         };
         dict["key_24"] = {
            "cn":"水 超能",
            "en":"water_psychic"
         };
         dict["key_25"] = {
            "cn":"水 暗影",
            "en":"water_dark"
         };
         dict["key_26"] = {
            "cn":"水 龙",
            "en":"water_dragon"
         };
         dict["key_27"] = {
            "cn":"火 飞行",
            "en":"fire_flying"
         };
         dict["key_28"] = {
            "cn":"火 龙",
            "en":"fire_dragon"
         };
         dict["key_29"] = {
            "cn":"火 超能",
            "en":"fire_psychic"
         };
         dict["key_30"] = {
            "cn":"飞行 超能",
            "en":"flying_psychic"
         };
         dict["key_31"] = {
            "cn":"光 飞行",
            "en":"flying_light"
         };
         dict["key_32"] = {
            "cn":"飞行 龙",
            "en":"flying_dragon"
         };
         dict["key_33"] = {
            "cn":"电 火",
            "en":"electric_fire"
         };
         dict["key_34"] = {
            "cn":"电 冰",
            "en":"electric_ice"
         };
         dict["key_35"] = {
            "cn":"电 战斗",
            "en":"electric_fight"
         };
         dict["key_36"] = {
            "cn":"暗影 电",
            "en":"electric_dark"
         };
         dict["key_37"] = {
            "cn":"机械 地面",
            "en":"steel_ground"
         };
         dict["key_38"] = {
            "cn":"机械 超能",
            "en":"steel_psychic"
         };
         dict["key_39"] = {
            "cn":"机械 龙",
            "en":"steel_dragon"
         };
         dict["key_40"] = {
            "cn":"地面 龙",
            "en":"ground_dragon"
         };
         dict["key_41"] = {
            "cn":"战斗 地面",
            "en":"ground_fight"
         };
         dict["key_42"] = {
            "cn":"地面 暗影",
            "en":"ground_dark"
         };
         dict["key_43"] = {
            "cn":"冰 龙",
            "en":"ice_dragon"
         };
         dict["key_44"] = {
            "cn":"冰 光",
            "en":"ice_light"
         };
         dict["key_45"] = {
            "cn":"冰 暗影",
            "en":"ice_dark"
         };
         dict["key_46"] = {
            "cn":"超能 冰",
            "en":"psychic_ice"
         };
         dict["key_47"] = {
            "cn":"战斗 火",
            "en":"fight_fire"
         };
         dict["key_48"] = {
            "cn":"战斗 暗影",
            "en":"fight_dark"
         };
         dict["key_49"] = {
            "cn":"光 神秘",
            "en":"light_myth"
         };
         dict["key_50"] = {
            "cn":"暗影 神秘",
            "en":"dark_myth"
         };
         dict["key_51"] = {
            "cn":"神秘 超能",
            "en":"myth_psychic"
         };
         dict["key_52"] = {
            "cn":"圣灵 光",
            "en":"saint_light"
         };
         dict["key_53"] = {
            "cn":"飞行 神秘",
            "en":"flying_myth"
         };
         dict["key_54"] = {
            "cn":"地面 超能",
            "en":"ground_psychic"
         };
         dict["key_55"] = {
            "cn":"暗影 龙",
            "en":"dark_dragon"
         };
         dict["key_56"] = {
            "cn":"圣灵 暗影",
            "en":"saint_dark"
         };
         dict["key_57"] = {
            "cn":"远古 战斗",
            "en":"ancient_fight"
         };
         dict["key_58"] = {
            "cn":"火 神秘",
            "en":"myth_fire"
         };
         dict["key_59"] = {
            "cn":"光 战斗",
            "en":"light_fight"
         };
         dict["key_60"] = {
            "cn":"神秘 战斗",
            "en":"myth_fight"
         };
         dict["key_61"] = {
            "cn":"次元 战斗",
            "en":"dimension_fight"
         };
         dict["key_62"] = {
            "cn":"邪灵 神秘",
            "en":"demon_myth"
         };
         dict["key_63"] = {
            "cn":"远古 龙",
            "en":"ancient_dragon"
         };
         dict["key_64"] = {
            "cn":"光 次元",
            "en":"light_dimension"
         };
         dict["key_65"] = {
            "cn":"远古 圣灵",
            "en":"ancient_saint"
         };
         dict["key_66"] = {
            "cn":"水 战斗",
            "en":"water_fight"
         };
         dict["key_67"] = {
            "cn":"电 龙",
            "en":"electric_dragon"
         };
         dict["key_68"] = {
            "cn":"光 火",
            "en":"light_fire"
         };
         dict["key_69"] = {
            "cn":"光 暗影",
            "en":"light_dark"
         };
         dict["key_70"] = {
            "cn":"邪灵 龙",
            "en":"demon_dragon"
         };
         dict["key_71"] = {
            "cn":"远古 神秘",
            "en":"ancient_myth"
         };
         dict["key_72"] = {
            "cn":"机械 次元",
            "en":"steel_dimension"
         };
         dict["key_73"] = {
            "cn":"战斗 龙",
            "en":"fight_dragon"
         };
         dict["key_74"] = {
            "cn":"战斗 自然",
            "en":"fight_nature"
         };
         dict["key_75"] = {
            "cn":"邪灵 机械",
            "en":"demon_steel"
         };
         dict["key_76"] = {
            "cn":"电 次元",
            "en":"electric_dimension"
         };
         dict["key_77"] = {
            "cn":"远古 火",
            "en":"ancient_fire"
         };
         dict["key_78"] = {
            "cn":"圣灵 战斗",
            "en":"saint_fight"
         };
         dict["key_79"] = {
            "cn":"圣灵 次元",
            "en":"saint_dimension"
         };
         dict["key_80"] = {
            "cn":"圣灵 电",
            "en":"saint_electric"
         };
         dict["key_81"] = {
            "cn":"远古 地面",
            "en":"ancient_ground"
         };
         dict["key_82"] = {
            "cn":"远古 草",
            "en":"ancient_grass"
         };
         dict["key_83"] = {
            "cn":"自然 龙",
            "en":"nature_dragon"
         };
         dict["key_84"] = {
            "cn":"冰 神秘",
            "en":"ice_myth"
         };
         dict["key_85"] = {
            "cn":"飞行 暗影",
            "en":"flying_dark"
         };
         dict["key_86"] = {
            "cn":"冰 火",
            "en":"ice_fire"
         };
         dict["key_87"] = {
            "cn":"冰 飞行",
            "en":"ice_flying"
         };
         dict["key_88"] = {
            "cn":"自然 圣灵",
            "en":"nature_saint"
         };
         dict["key_89"] = {
            "cn":"混沌 圣灵",
            "en":"chaos_saint"
         };
         dict["key_90"] = {
            "cn":"远古 邪灵",
            "en":"ancient_demon"
         };
         dict["key_91"] = {
            "cn":"自然 冰",
            "en":"nature_ice"
         };
         dict["key_92"] = {
            "cn":"混沌 暗影",
            "en":"chaos_dark"
         };
         dict["key_93"] = {
            "cn":"混沌 战斗",
            "en":"chaos_fight"
         };
         dict["key_94"] = {
            "cn":"混沌 超能",
            "en":"chaos_psychic"
         };
         dict["key_95"] = {
            "cn":"圣灵 超能",
            "en":"saint_psychic"
         };
         dict["key_96"] = {
            "cn":"混沌 地面",
            "en":"chaos_ground"
         };
         dict["key_97"] = {
            "cn":"暗影 邪灵",
            "en":"dark_demon"
         };
         dict["key_98"] = {
            "cn":"混沌 远古",
            "en":"chaos_ancient"
         };
         dict["key_99"] = {
            "cn":"混沌 邪灵",
            "en":"chaos_demon"
         };
         dict["key_100"] = {
            "cn":"圣灵 地面",
            "en":"saint_ground"
         };
         dict["key_101"] = {
            "cn":"火 暗影",
            "en":"fire_dark"
         };
         dict["key_102"] = {
            "cn":"光 超能",
            "en":"light_psychic"
         };
         dict["key_103"] = {
            "cn":"机械 战斗",
            "en":"steel_fight"
         };
         dict["key_104"] = {
            "cn":"飞行 电",
            "en":"flying_electric"
         };
         dict["key_105"] = {
            "cn":"混沌 飞行",
            "en":"chaos_flying"
         };
         dict["key_106"] = {
            "cn":"混沌 龙",
            "en":"chaos_dragon"
         };
         dict["key_107"] = {
            "cn":"混沌 火",
            "en":"chaos_fire"
         };
         dict["key_108"] = {
            "cn":"圣灵 火",
            "en":"saint_fire"
         };
         dict["key_109"] = {
            "cn":"地面 神秘",
            "en":"ground_myth"
         };
         dict["key_110"] = {
            "cn":"混沌 次元",
            "en":"chaos_dimension"
         };
         dict["key_111"] = {
            "cn":"混沌 冰",
            "en":"chaos_ice"
         };
         dict["key_112"] = {
            "cn":"自然 神秘",
            "en":"nature_myth"
         };
         dict["key_113"] = {
            "cn":"虚空 邪灵",
            "en":"void_demon"
         };
         dict["key_114"] = {
            "cn":"虚空 混沌",
            "en":"void_chaos"
         };
         dict["key_115"] = {
            "cn":"圣灵 轮回",
            "en":"saint_samsara"
         };
         dict["key_116"] = {
            "cn":"水 次元",
            "en":"water_dimension"
         };
         dict["key_117"] = {
            "cn":"圣灵 神秘",
            "en":"saint_myth"
         };
         dict["key_118"] = {
            "cn":"机械 神秘",
            "en":"steel_myth"
         };
         dict["key_119"] = {
            "cn":"水 神秘",
            "en":"water_myth"
         };
         dict["key_120"] = {
            "cn":"次元 龙",
            "en":"dimension_dragon"
         };
         dict["key_121"] = {
            "cn":"自然 超能",
            "en":"nature_psychic"
         };
         dict["key_122"] = {
            "cn":"电 机械",
            "en":"electric_steel"
         };
         dict["key_123"] = {
            "cn":"神秘 轮回",
            "en":"myth_samsara"
         };
         dict["key_124"] = {
            "cn":"水 机械",
            "en":"water_steel"
         };
         dict["key_125"] = {
            "cn":"火 机械",
            "en":"fire_steel"
         };
         dict["key_126"] = {
            "cn":"草 机械",
            "en":"grass_steel"
         };
         dict["key_127"] = {
            "cn":"远古 电",
            "en":"ancient_electric"
         };
         dict["key_221"] = {
            "cn":"王",
            "en":"king"
         };
         dict["key_222"] = {
            "cn":"混沌",
            "en":"chaos"
         };
         dict["key_223"] = {
            "cn":"神灵",
            "en":"deity"
         };
         dict["key_224"] = {
            "cn":"轮回",
            "en":"samsara"
         };
         dict["key_225"] = {
            "cn":"虫",
            "en":"insect"
         };
         dict["key_226"] = {
            "cn":"虚空",
            "en":"void"
         };
         categoryNames["key_1"] = "物理攻击";
         categoryNames["key_2"] = "特殊攻击";
         categoryNames["key_4"] = "属性攻击";
      }
      
      public static function getName(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Name;
      }
      
      public static function getDamage(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Power;
      }
      
      public static function getPP(param1:uint) : uint
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@MaxPP;
      }
      
      public static function hitP(param1:uint) : Number
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Accuracy;
      }
      
      public static function getSideEffects(param1:uint) : Array
      {
         var xml:XML = null;
         var _add:Array = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         _add = String(xml.@SideEffect).split(" ");
         return _add;
      }
      
      public static function getSideEffectArgs(param1:uint) : Array
      {
         var xml:XML = null;
         var _add:Array = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         _add = String(xml.@SideEffectArg).split(" ");
         return _add;
      }
      
      public static function getCategory(param1:uint) : int
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         if(!xml)
         {
            return 0;
         }
         return xml.@Category;
      }
      
      public static function getCategoryName(param1:uint) : String
      {
         return categoryNames["key_" + getCategory(param1)];
      }
      
      public static function getTypeCN(param1:uint) : String
      {
         var xml:XML = null;
         var type:String = null;
         var id:uint = param1;
         if(getCategory(id) == 4)
         {
            return "属性";
         }
         xml = xmllist.(@ID == id)[0];
         type = xml.@Type;
         return dict["key_" + type]["cn"];
      }
      
      public static function getTypeCNBytTypeID(param1:uint) : String
      {
         return dict["key_" + param1]["cn"];
      }
      
      public static function getTypeEN(param1:uint) : String
      {
         var xml:XML = null;
         var type:String = null;
         var id:uint = param1;
         if(getCategory(id) == 4)
         {
            return "prop";
         }
         xml = xmllist.(@ID == id)[0];
         type = xml.@Type;
         return dict["key_" + type]["en"];
      }
      
      public static function getInfo(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@info;
      }
      
      public static function getDes(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = sideEffectXMLList.(@ID == id)[0];
         return xml.@des;
      }
      
      public static function petTypeName(param1:uint) : String
      {
         var _loc2_:String = dict["key_" + param1]["cn"];
         return dict["key_" + param1]["cn"];
      }
      
      public static function getPriority(param1:uint) : int
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return Boolean(xml.@Priority) ? int(xml.@Priority) : 0;
      }
      
      public static function getUrl(param1:uint) : String
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return xml.@Url;
      }
      
      public static function getCritRate(param1:uint) : int
      {
         var xml:XML = null;
         var id:uint = param1;
         xml = xmllist.(@ID == id)[0];
         return Boolean(xml.@CritRate) ? int(xml.@CritRate) : 1;
      }
      
      public static function getMustHit(param1:uint) : Number
      {
         var id:uint = param1;
         var xml:* = 0;
         xml = xmllist.(@ID == id)[0];
         return xml.@MustHit;
      }
   }
}

