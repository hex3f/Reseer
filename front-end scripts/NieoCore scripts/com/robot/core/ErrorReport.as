package com.robot.core
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.Capabilities;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   
   public class ErrorReport
   {
      
      public static const PATH:String = "http://114.80.98.38/cgi-bin/stat/seer-err-report.cgi";
      
      public static const MIMI_LOGIN_ERROR:uint = 1;
      
      public static const EMAIL_LOGIN_ERROR:uint = 2;
      
      public static const GET_SERVER_LIST_ERROR:uint = 3;
      
      public static const LOGIN_ONLINE_ERROR:uint = 4;
      
      public static const REGISTE_ERROR:uint = 5;
      
      public static const CREATE_SEER_ERROR:uint = 6;
      
      public static const LOGIN_HOME_ONLINE_ERROR:uint = 7;
      
      public static const SOCKET_CLOSE_ERROR:uint = 8;
      
      public static const RESOURCE_MANAGER_ERROR:uint = 9;
      
      public static const RESOURCE_REFLECT_ERROR:uint = 10;
      
      setup();
      
      public function ErrorReport()
      {
         super();
      }
      
      private static function setup() : void
      {
         EventManager.addEventListener(ResourceManager.RESOUCE_REFLECT_ERROR,function(param1:Event):void
         {
            sendError(RESOURCE_REFLECT_ERROR);
         });
         EventManager.addEventListener(ResourceManager.RESOUCE_ERROR,function(param1:Event):void
         {
            sendError(RESOURCE_MANAGER_ERROR);
         });
      }
      
      public static function sendError(param1:uint) : void
      {
         var _loc2_:URLLoader = new URLLoader();
         var _loc3_:URLVariables = new URLVariables();
         var _loc4_:Date = new Date();
         _loc3_.date = _loc4_.getFullYear() + "/" + (_loc4_.getMonth() + 1) + "/" + _loc4_.getDate() + "/" + _loc4_.getHours() + ":" + _loc4_.getMinutes();
         _loc3_.serverIP = getIP(param1);
         _loc3_.serverPort = getPort(param1);
         _loc3_.version = ClientConfig.uiVersion;
         _loc3_.id = MainManager.actorID;
         if(Boolean(MainManager.actorModel))
         {
            _loc3_.x = MainManager.actorModel.x;
            _loc3_.y = MainManager.actorModel.y;
         }
         else
         {
            _loc3_.x = 0;
            _loc3_.y = 0;
         }
         if(Boolean(MainManager.actorInfo))
         {
            _loc3_.mapID = MainManager.actorInfo.mapID;
         }
         else
         {
            _loc3_.mapID = 0;
         }
         _loc3_.serverID = MainManager.serverID;
         _loc3_.playerType = Capabilities.playerType;
         _loc3_.playerVersion = Capabilities.version;
         _loc3_.isDebugger = Capabilities.isDebugger;
         _loc3_.os = Capabilities.os;
         _loc3_.language = Capabilities.language;
         var _loc5_:URLRequest = new URLRequest(PATH + "?folder=" + param1);
         _loc5_.method = URLRequestMethod.POST;
         _loc5_.data = _loc3_;
         _loc2_.load(_loc5_);
      }
      
      private static function getIP(param1:uint) : String
      {
         var _loc2_:String = null;
         if(param1 == MIMI_LOGIN_ERROR || param1 == EMAIL_LOGIN_ERROR)
         {
            _loc2_ = ClientConfig.ID_IP;
         }
         else if(param1 == GET_SERVER_LIST_ERROR || param1 == CREATE_SEER_ERROR)
         {
            _loc2_ = ClientConfig.SUB_SERVER_IP;
         }
         return _loc2_;
      }
      
      private static function getPort(param1:uint) : uint
      {
         var _loc2_:int = 0;
         if(param1 == MIMI_LOGIN_ERROR || param1 == EMAIL_LOGIN_ERROR)
         {
            _loc2_ = int(ClientConfig.ID_PORT);
         }
         else if(param1 == GET_SERVER_LIST_ERROR || param1 == CREATE_SEER_ERROR)
         {
            _loc2_ = int(ClientConfig.SUB_SERVER_PORT);
         }
         return _loc2_;
      }
   }
}

