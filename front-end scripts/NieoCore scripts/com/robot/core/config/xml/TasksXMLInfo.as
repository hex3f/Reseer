package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import org.taomee.ds.HashMap;
   
   public class TasksXMLInfo
   {
      
      private static var _dataMap:HashMap;
      
      private static const PRO:String = "pro";
      
      private static var xmlClass:Class = TasksXMLInfo_xmlClass;
      
      setup();
      
      public function TasksXMLInfo()
      {
         super();
      }
      
      public static function get dataMap() : HashMap
      {
         return _dataMap;
      }
      
      private static function setup() : void
      {
         var _loc1_:XML = null;
         var _loc2_:* = 0;
         _dataMap = new HashMap();
         var _loc3_:XMLList = XML(new xmlClass()).elements("task");
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = uint(_loc1_.@ID);
            _dataMap.add(_loc2_,_loc1_);
         }
      }
      
      public static function getName(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@name.toString();
         }
         return "";
      }
      
      public static function getEspecial(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(uint(_loc2_.@especial));
         }
         return false;
      }
      
      public static function getDoc(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@doc.toString();
         }
         return "";
      }
      
      public static function getAlert(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.@alert.toString();
         }
         return "";
      }
      
      public static function isMat(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@isMat));
         }
         return false;
      }
      
      public static function getType(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@type);
         }
         return 0;
      }
      
      public static function isEnd(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@isEnd));
         }
         return false;
      }
      
      public static function isDir(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@isDir));
         }
         return false;
      }
      
      public static function getParent(param1:uint) : Array
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc4_))
         {
            _loc2_ = _loc4_.@parent.toString();
            if(_loc2_ == "")
            {
               return [];
            }
            return _loc2_.split("|");
         }
         return [];
      }
      
      public static function getTaskPorCount(param1:uint) : int
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return _loc2_.elements(PRO).length();
         }
         return 0;
      }
      
      public static function getProName(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@name.toString();
         }
         return "";
      }
      
      public static function getProDoc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@doc.toString();
         }
         return "";
      }
      
      public static function getProAlert(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return _loc3_.elements(PRO)[param2].@alert.toString();
         }
         return "";
      }
      
      public static function getProParent(param1:uint, param2:uint) : Array
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc5_))
         {
            _loc3_ = _loc5_.elements(PRO)[param2].@parent.toString();
            if(_loc3_ == "")
            {
               return [];
            }
            return _loc3_.split("|");
         }
         return [];
      }
      
      public static function isProMat(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            return Boolean(int(_loc3_.elements(PRO)[param2].@isMat));
         }
         return false;
      }
      
      public static function getTaskDes(param1:uint) : String
      {
         var _loc2_:String = null;
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            _loc2_ = String(_loc3_.taskDes);
            return _loc2_.replace(/#nick/g,MainManager.actorInfo.nick);
         }
         return "";
      }
      
      public static function getProDes(param1:uint) : String
      {
         var _loc2_:String = null;
         var _loc3_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc3_))
         {
            _loc2_ = String(_loc3_.proDes);
            return _loc2_.replace(/#nick/g,MainManager.actorInfo.nick);
         }
         return "";
      }
      
      public static function getIsCondition(param1:uint) : Boolean
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@condition));
         }
         return false;
      }
   }
}

