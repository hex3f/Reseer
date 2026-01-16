package com.robot.core.config.xml
{
   import com.robot.core.manager.MainManager;
   import org.taomee.ds.HashMap;
   
   public class MachXMLInfo
   {
      
      private static var xmlClass:Class = MachXMLInfo_xmlClass;
      
      private static var _actionMap:HashMap = new HashMap();
      
      private static var _expMap:HashMap = new HashMap();
      
      private static var _linesMap:HashMap = new HashMap();
      
      private static var _superExpMap:HashMap = new HashMap();
      
      private static var _superLinesMap:HashMap = new HashMap();
      
      setup();
      
      public function MachXMLInfo()
      {
         super();
      }
      
      private static function setup() : void
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         _loc1_ = XML(new xmlClass()).elements("action")[0].elements("item");
         for each(_loc2_ in _loc1_)
         {
            _actionMap.add(uint(_loc2_.@id),_loc2_);
         }
         _loc1_ = XML(new xmlClass()).elements("exp")[0].elements("item");
         for each(_loc2_ in _loc1_)
         {
            _expMap.add(uint(_loc2_.@id),_loc2_);
         }
         _loc1_ = XML(new xmlClass()).elements("lines")[0].elements("item");
         for each(_loc2_ in _loc1_)
         {
            _linesMap.add(uint(_loc2_.@id),_loc2_);
         }
         _loc1_ = XML(new xmlClass()).elements("superExp")[0].elements("item");
         for each(_loc2_ in _loc1_)
         {
            _superExpMap.add(uint(_loc2_.@id),_loc2_);
         }
         _loc1_ = XML(new xmlClass()).elements("superLines")[0].elements("item");
         for each(_loc2_ in _loc1_)
         {
            _superLinesMap.add(uint(_loc2_.@id),_loc2_);
         }
      }
      
      public static function getActionName(param1:uint) : String
      {
         var _loc2_:XML = _actionMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@name);
         }
         return "";
      }
      
      public static function getExpName(param1:uint) : String
      {
         var _loc2_:XML = null;
         if(MainManager.actorInfo.superNono)
         {
            _loc2_ = _superExpMap.getValue(param1);
         }
         else
         {
            _loc2_ = _expMap.getValue(param1);
         }
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@name);
         }
         return "";
      }
      
      public static function getLinesName(param1:uint) : String
      {
         var _loc2_:XML = null;
         if(MainManager.actorInfo.superNono)
         {
            _loc2_ = _superLinesMap.getValue(param1);
         }
         else
         {
            _loc2_ = _linesMap.getValue(param1);
         }
         if(Boolean(_loc2_))
         {
            return String(_loc2_.@name);
         }
         return "";
      }
      
      public static function getActionIsAutoEnd(param1:uint) : Boolean
      {
         var _loc2_:XML = _actionMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return Boolean(int(_loc2_.@autoEnd));
         }
         return true;
      }
      
      public static function getActionSouLoops(param1:uint) : int
      {
         var _loc2_:XML = _actionMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            if(!_loc2_.hasOwnProperty("@souLoops"))
            {
               return 0;
            }
            return int(_loc2_.@souLoops);
         }
         return 0;
      }
      
      public static function getExpID() : Array
      {
         var arr:Array = null;
         var xmlArr:Array = null;
         arr = null;
         if(MainManager.actorInfo.superNono)
         {
            xmlArr = _superExpMap.getValues();
         }
         else
         {
            xmlArr = _expMap.getValues();
         }
         arr = [];
         xmlArr.forEach(function(param1:XML, param2:int, param3:Array):void
         {
            var _loc4_:int = int(param1.@odds);
            var _loc5_:uint = uint(param1.@id);
            var _loc6_:int = 0;
            while(_loc6_ < _loc4_)
            {
               arr.push(_loc5_);
               _loc6_++;
            }
         });
         return arr;
      }
      
      public static function getLinesIDForExp(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:Number = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(MainManager.actorInfo.superNono)
         {
            _loc4_ = _superExpMap.getValue(param1);
         }
         else
         {
            _loc4_ = _expMap.getValue(param1);
         }
         if(Boolean(_loc4_))
         {
            _loc5_ = String(_loc4_.@lines);
            _loc6_ = _loc5_.split(",");
            _loc7_ = [];
            for each(_loc8_ in _loc6_)
            {
               if(MainManager.actorInfo.superNono)
               {
                  _loc4_ = _superLinesMap.getValue(_loc8_);
               }
               else
               {
                  _loc4_ = _linesMap.getValue(param1);
               }
               if(Boolean(_loc4_))
               {
                  _loc9_ = String(_loc4_.@energy);
                  if(_loc9_.indexOf(param2.toString()) != -1)
                  {
                     _loc10_ = String(_loc4_.@mate);
                     if(_loc10_.indexOf(param3.toString()) != -1)
                     {
                        _loc7_.push(_loc8_);
                     }
                  }
               }
            }
            return _loc7_;
         }
         return [];
      }
   }
}

