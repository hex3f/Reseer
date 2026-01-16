package com.robot.app.task.taskProStep
{
   import com.robot.core.manager.*;
   import org.taomee.ds.*;
   
   public class TaskStepXMLInfo
   {
      
      private static var _taskStepXML:XML;
      
      private static var _dataMap:HashMap;
      
      public function TaskStepXMLInfo()
      {
         super();
      }
      
      public static function setup(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:uint = 0;
         if(param1 == null)
         {
            return;
         }
         _dataMap = new HashMap();
         var _loc4_:XMLList = param1.elements("pro");
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = uint(_loc2_.@id);
            _dataMap.add(_loc3_,_loc2_);
         }
      }
      
      public static function get proCnt() : uint
      {
         return _dataMap.length;
      }
      
      public static function getProDes(param1:uint) : String
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return String(_loc2_.des);
         }
         return "";
      }
      
      public static function getProMapID(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            return uint(_loc2_.@mapID);
         }
         return 0;
      }
      
      public static function getStepList(param1:uint) : Array
      {
         var _loc2_:XML = null;
         var _loc3_:Array = [];
         var _loc4_:XML = _dataMap.getValue(param1) as XML;
         if(_loc4_ == null)
         {
            return [];
         }
         var _loc5_:XMLList = _loc4_.step;
         for each(_loc2_ in _loc5_)
         {
            _loc3_.push(_loc2_.@type);
         }
         return _loc3_;
      }
      
      public static function getStepCnt(param1:uint) : uint
      {
         var _loc2_:XML = _dataMap.getValue(param1);
         var _loc3_:XMLList = _loc2_.step;
         if(Boolean(_loc3_))
         {
            return _loc3_.length();
         }
         return 0;
      }
      
      public static function getStepXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = null;
         var _loc4_:XML = _dataMap.getValue(param1);
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc5_:XMLList = _loc4_.step;
         for each(_loc3_ in _loc5_)
         {
            if(_loc3_.@id == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public static function getStepType(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.@type;
      }
      
      public static function getStepGoto(param1:uint, param2:uint) : Array
      {
         var _loc3_:XML = getStepXML(param1,param2);
         var _loc4_:String = String(_loc3_["@goto"]);
         return _loc4_.split("_");
      }
      
      public static function getStepIsComplete(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return Boolean(uint(_loc3_.@isCompletePro));
      }
      
      public static function getStepOptionXML(param1:uint, param2:uint, param3:uint) : XML
      {
         var _loc4_:XML = getStepXML(param1,param2);
         return XML(_loc4_.option[param3]);
      }
      
      public static function getStepOptionCnt(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return (_loc3_.option as XMLList).length();
      }
      
      public static function getStepOptionGoto(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc4_:XML = getStepOptionXML(param1,param2,param3);
         return String(_loc4_["@goto"]).split("_");
      }
      
      public static function getStepOptionDes(param1:uint, param2:uint, param3:uint) : String
      {
         var _loc4_:XML = getStepOptionXML(param1,param2,param3);
         return _loc4_.@des;
      }
      
      public static function getStepTalkXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.talk[0];
      }
      
      public static function getStepTalkNpc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepTalkXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@npcName;
         }
         return "";
      }
      
      public static function getStepTalkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepTalkXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@talkMcName;
         }
         return "";
      }
      
      public static function getStepTalkDes(param1:uint, param2:uint) : String
      {
         var _loc3_:String = null;
         var _loc4_:XML = getStepTalkXML(param1,param2);
         if(Boolean(_loc4_))
         {
            _loc3_ = String(_loc4_.talkDes);
            return _loc3_.replace(/#nick/g,MainManager.actorInfo.nick);
         }
         return "";
      }
      
      public static function getStepTalkFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:String = null;
         var _loc4_:XML = getStepTalkXML(param1,param2);
         if(Boolean(_loc4_))
         {
            return _loc4_.@func;
         }
         return "";
      }
      
      public static function getStepMcXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.mc[0];
      }
      
      public static function getStepMcSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         return _loc3_.@sparkMC;
      }
      
      public static function getStepMcType(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         return _loc3_.@type;
      }
      
      public static function getStepMcName(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         return _loc3_.@name;
      }
      
      public static function getStepMcVisible(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         return Boolean(uint(_loc3_.@visible));
      }
      
      public static function getStepMcFrame(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         if(uint(_loc3_.@frame) != 0)
         {
            return _loc3_.@frame;
         }
         return 1;
      }
      
      public static function getStepMcFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepMcXML(param1,param2);
         return _loc3_.@func;
      }
      
      public static function getStepSceenMovieXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.sceenMovie[0];
      }
      
      public static function getStepSmSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepSceenMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@sparkMC;
         }
         return "";
      }
      
      public static function getStepSmPlaySceenMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepSceenMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@playSceenMC;
         }
         return "";
      }
      
      public static function getStepSmPlayMcFrame(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = getStepSceenMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@frame;
         }
         return 0;
      }
      
      public static function getStepSmPlayMcChild(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepSceenMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@childMcName;
         }
         return "";
      }
      
      public static function getStepSmFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepSceenMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@func;
         }
         return "";
      }
      
      public static function getStepFullMovieXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.fullMovie[0];
      }
      
      public static function getStepFmSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFullMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@sparkMC;
         }
         return "";
      }
      
      public static function getStepFullMovieUrl(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFullMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@playMovieURL;
         }
         return "";
      }
      
      public static function getStepFmFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFullMovieXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@func;
         }
         return "";
      }
      
      public static function getStepGameXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.game[0];
      }
      
      public static function getStepGmSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepGameXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@sparkMC;
         }
         return "";
      }
      
      public static function getStepGameUrl(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepGameXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@playGameURL;
         }
         return "";
      }
      
      public static function getStepGamePassFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepGameXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@passGameFunc;
         }
         return "";
      }
      
      public static function getStepGameLossFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepGameXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@loseGameFunc;
         }
         return "";
      }
      
      public static function getStepFightXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.fight[0];
      }
      
      public static function getStepFtSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFightXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@sparkMC;
         }
         return "";
      }
      
      public static function getStepFtBossID(param1:uint, param2:uint) : uint
      {
         var _loc3_:XML = getStepFightXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@fightBossID;
         }
         return 0;
      }
      
      public static function getStepFtBossName(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFightXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@fightBossName;
         }
         return "";
      }
      
      public static function getStepFtSuccessFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFightXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@fightSuccessFunc;
         }
         return "";
      }
      
      public static function getStepFtLossFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepFightXML(param1,param2);
         if(Boolean(_loc3_))
         {
            return _loc3_.@fightLoseFunc;
         }
         return "";
      }
      
      public static function getStepPanelXML(param1:uint, param2:uint) : XML
      {
         var _loc3_:XML = getStepXML(param1,param2);
         return _loc3_.panel[0];
      }
      
      public static function getStepPanelSparkMC(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepPanelXML(param1,param2);
         return _loc3_.@sparkMC;
      }
      
      public static function getStepPanelClass(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepPanelXML(param1,param2);
         return _loc3_.@className;
      }
      
      public static function getStepPanelFunc(param1:uint, param2:uint) : String
      {
         var _loc3_:XML = getStepPanelXML(param1,param2);
         return _loc3_.@func;
      }
   }
}

