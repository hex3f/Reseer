package com.robot.app.tasksRecord
{
   import com.robot.core.utils.TextFormatUtil;
   
   public class TasksRecordConfig
   {
      
      private static var _allIdA:Array;
      
      private static var xmlClass:Class = TasksRecordConfig_xmlClass;
      
      private static var xml:XML = XML(new xmlClass());
      
      public function TasksRecordConfig()
      {
         super();
      }
      
      public static function getStarIDByName(param1:String) : String
      {
         var name:String = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("star");
         xml = xmlList.(@name == name)[0];
         return xml.@id;
      }
      
      public static function getXML() : XML
      {
         return xml.copy();
      }
      
      public static function getTaskLength() : uint
      {
         var _loc1_:XMLList = xml.elements("task");
         return _loc1_.length();
      }
      
      public static function getAllTasksId() : Array
      {
         var _loc1_:XML = null;
         var _loc2_:XMLList = xml.elements("task");
         _allIdA = new Array();
         for each(_loc1_ in _loc2_)
         {
            _allIdA.push(uint(_loc1_.@id));
         }
         return _allIdA;
      }
      
      public static function get allIdA() : Array
      {
         if(!_allIdA)
         {
            _allIdA = new Array();
         }
         return _allIdA;
      }
      
      public static function getName(param1:uint) : String
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         return xml.@name;
      }
      
      public static function getIsVip(param1:uint) : Boolean
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         if(Boolean(xml.hasOwnProperty("@isVip")))
         {
            return Boolean(xml.@isVip);
         }
         return false;
      }
      
      public static function getParentId(param1:uint) : uint
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var parentId:uint = 0;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         parentId = uint(xml.@parentId);
         return parentId;
      }
      
      public static function getOnlineData(param1:uint) : Number
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var data:Number = NaN;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         data = Number(xml.@onlineData);
         return data;
      }
      
      public static function getTaskNpcForId(param1:uint) : String
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var npcName:String = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         npcName = xml.@npc;
         return npcName;
      }
      
      public static function getTaskNpcTips(param1:uint) : String
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var npcName:String = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         npcName = xml.@tip;
         return npcName;
      }
      
      public static function getTaskOffLineForId(param1:uint) : Boolean
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         return Boolean(uint(xml.@offline));
      }
      
      public static function getTaskNewOnlineForId(param1:uint) : Boolean
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         return Boolean(uint(xml.@newOnline));
      }
      
      public static function getAltTaskMapId(param1:uint) : uint
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         return uint(xml.@mapId);
      }
      
      public static function getTaskType(param1:uint) : uint
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         return uint(xml.@type);
      }
      
      public static function getTaskStartDes(param1:uint) : String
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var des:String = null;
         var a:Array = null;
         var i1:int = 0;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         des = xml.startDes;
         if(des.indexOf("#") == -1)
         {
            return des;
         }
         a = des.split("#");
         a[a.length - 1] = TextFormatUtil.getRedTxt(a[a.length - 1]);
         des = "";
         i1 = 0;
         while(i1 < a.length)
         {
            des += a[i1];
            i1++;
         }
         return des;
      }
      
      public static function getTaskStopDes(param1:uint) : String
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var des:String = null;
         var a:Array = null;
         var i1:int = 0;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         des = xml.stopDes;
         if(des.indexOf("#") == -1)
         {
            return des;
         }
         a = des.split("#");
         a[a.length - 1] = TextFormatUtil.getRedTxt(a[a.length - 1]);
         des = "";
         i1 = 0;
         while(i1 < a.length)
         {
            des += a[i1];
            i1++;
         }
         return des;
      }
      
      public static function getTaskReward(param1:uint) : Array
      {
         var id:uint = param1;
         var xmlList:XMLList = null;
         var xml:XML = null;
         var des:String = null;
         var arr:Array = null;
         var i:uint = 0;
         var ar:Array = null;
         var i2:int = 0;
         var str:String = null;
         var a:Array = null;
         var i1:int = 0;
         xmlList = xml.descendants("task");
         xml = xmlList.(@id == id.toString())[0];
         des = xml.outPut;
         if(des.indexOf("|") == -1)
         {
            if(des.indexOf("#") == -1)
            {
               return [des];
            }
            ar = des.split("#");
            ar[ar.length - 1] = TextFormatUtil.getRedTxt(ar[ar.length - 1]);
            des = "";
            i2 = 0;
            while(i2 < ar.length)
            {
               des += ar[i2];
               i2++;
            }
            return [des];
         }
         arr = des.split("|");
         i = 0;
         while(i < arr.length)
         {
            str = arr[i];
            if(str.indexOf("#") != -1)
            {
               a = str.split("#");
               a[a.length - 1] = TextFormatUtil.getRedTxt(a[a.length - 1]);
               str = "";
               i1 = 0;
               while(i1 < a.length)
               {
                  str += a[i1];
                  i1++;
               }
               arr[i] = str;
            }
            i++;
         }
         return arr;
      }
   }
}

