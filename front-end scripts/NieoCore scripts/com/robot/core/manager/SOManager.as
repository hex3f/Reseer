package com.robot.core.manager
{
   import flash.net.SharedObject;
   import org.taomee.utils.SOFlushPool;
   
   public class SOManager
   {
      
      private static var flushPool:SOFlushPool;
      
      public static const INFO:String = "info";
      
      public static const LOGIN:String = "login";
      
      public static const NEWS:String = "news";
      
      public static const SPT:String = "spt";
      
      public static const NoNOBook:String = "nonobook";
      
      public static const NoNoChipMic:String = "nonochipmic";
      
      public static const RELATION:String = "relation";
      
      public static const TEAM_MB:String = "teamMember";
      
      public static const TASK_RECORD:String = "taskRecord";
      
      public static const ARMBOOK_READED:String = "armBookReaded";
      
      public static const ARM_EXCHANGEBOOK_READED:String = "armExchangeBookReaded";
      
      public static const Is_Readed_DarkBook:String = "isReadedDarkBook";
      
      public static const Is_Readed_MonsterBook:String = "isReadedMonsterBook";
      
      public static const Is_Readed_ShopingBook:String = "isReadedShopingBook";
      
      public static const MINE_400010:String = "MINE_400010";
      
      public static const MINE_400011:String = "MINE_400011";
      
      public static const MINE_400012:String = "MINE_400012";
      
      public static const DAILY_TASK:String = "dailyTask";
      
      public static const READEDSHOPINGBOOK:String = "readedshopingbook";
      
      public static const LOCAL_CONFIG:String = "localConfig";
      
      public function SOManager()
      {
         super();
      }
      
      public static function getCommonSO(param1:String) : SharedObject
      {
         return SharedObject.getLocal("common/" + param1,"/");
      }
      
      public static function getUserSO(param1:String) : SharedObject
      {
         return SharedObject.getLocal(MainManager.actorID + "/" + param1,"/");
      }
      
      private static function getFlushPool() : SOFlushPool
      {
         if(flushPool == null)
         {
            flushPool = new SOFlushPool();
         }
         return flushPool;
      }
      
      public static function flush(param1:SharedObject) : Boolean
      {
         if(param1 != null)
         {
            getFlushPool().addFlush(param1);
            return true;
         }
         return false;
      }
      
      public static function getUser_Info() : SharedObject
      {
         return getUserSO(INFO);
      }
      
      public static function getUser_Relation() : SharedObject
      {
         return getUserSO(RELATION);
      }
      
      public static function getUser_SPT() : SharedObject
      {
         return getUserSO(SPT);
      }
      
      public static function getCommon_login() : SharedObject
      {
         return getCommonSO(LOGIN);
      }
      
      public static function getNews_Read() : SharedObject
      {
         return getCommonSO(NEWS);
      }
      
      public static function getNoNoBook_Read() : SharedObject
      {
         return getCommonSO(NoNOBook);
      }
      
      public static function getNoNoChipBook_Read() : SharedObject
      {
         return getCommonSO(NoNoChipMic);
      }
   }
}

