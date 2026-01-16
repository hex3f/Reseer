package com.robot.core.controller
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.SOManager;
   import flash.net.SharedObject;
   
   public class SaveUserInfo
   {
      
      private static const USERCOUNT:int = 3;
      
      private static var mySo:SharedObject = SOManager.getCommon_login();
      
      public static var isSave:Boolean = false;
      
      public static var pass:String = "";
      
      private static var vesion:uint = 0;
      
      private static var newsSo:SharedObject = SOManager.getNews_Read();
      
      public function SaveUserInfo()
      {
         super();
      }
      
      public static function saveSo() : void
      {
         var _loc1_:int = 0;
         if(!SaveUserInfo.isSave)
         {
            return;
         }
         var _loc2_:Array = SaveUserInfo.getUserInfo();
         if(_loc2_ == null)
         {
            _loc2_ = new Array();
         }
         else if(_loc2_.length <= USERCOUNT)
         {
            _loc1_ = 0;
            while(_loc1_ < _loc2_.length)
            {
               if(MainManager.actorID == _loc2_[_loc1_].id)
               {
                  _loc2_.splice(_loc1_,1);
               }
               _loc1_++;
            }
         }
         _loc2_.push({
            "id":MainManager.actorID,
            "nickName":MainManager.actorInfo.nick,
            "color":MainManager.actorInfo.color,
            "pwd":SaveUserInfo.pass,
            "clothes":MainManager.actorInfo.clothIDs,
            "texture":MainManager.actorInfo.texture
         });
         if(_loc2_.length > 3)
         {
            _loc2_.shift();
         }
         mySo.data.ousers = _loc2_;
         SOManager.flush(mySo);
      }
      
      public static function saveNewsSO() : void
      {
         vesion = ClientConfig.newsVersion;
         newsSo.data.version = vesion;
         newsSo.data.userId = MainManager.actorInfo.userID;
         SOManager.flush(newsSo);
      }
      
      public static function getUserInfo() : Array
      {
         return mySo.data.ousers;
      }
      
      public static function getNewsVersion() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.id = newsSo.data.userId;
         _loc1_.version = newsSo.data.version;
         return _loc1_;
      }
   }
}

