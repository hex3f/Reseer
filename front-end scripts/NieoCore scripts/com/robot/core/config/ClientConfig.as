package com.robot.core.config
{
   public class ClientConfig
   {
      
      private static var clientXML:XML;
      
      private static var _resURL:String;
      
      private static var _moduleURL:String;
      
      private static var _taskModuleURL:String;
      
      private static var _taskItemIconURL:String;
      
      private static var _bookModuleURL:String;
      
      private static var _gameModuleURL:String;
      
      private static var _helpModuleURL:String;
      
      private static var _npcURL:String;
      
      private static var _mailTemplateURL:String;
      
      private static var _clothLightURL:String;
      
      private static var _transformURL:String;
      
      public function ClientConfig()
      {
         super();
      }
      
      public static function setup(param1:XML) : void
      {
         ServerConfig.setup(param1);
         clientXML = param1;
         _resURL = clientXML.Res[0].@url.toString();
         _moduleURL = clientXML.AppModule[0].@url.toString();
         _taskModuleURL = clientXML.TaskModule[0].@url.toString();
         _taskItemIconURL = clientXML.TaskItemIconURL[0].@url.toString();
         _bookModuleURL = clientXML.BookModule[0].@url.toString();
         _gameModuleURL = clientXML.GameModule[0].@url.toString();
         _helpModuleURL = clientXML.HelpModule[0].@url.toString();
         _npcURL = param1.Npc[0].@url.toString();
         _mailTemplateURL = clientXML.MailTemplateURL[0].@url.toString();
         _clothLightURL = clientXML.ClothLight[0].@url.toString();
         _transformURL = clientXML.Transform[0].@url.toString();
      }
      
      public static function getXmlPath(param1:String) : String
      {
         return "config/" + clientXML.XML.elements(param1).@path.toString();
      }
      
      public static function getUrl(param1:String) : String
      {
         return clientXML.URL.elements(param1).toString();
      }
      
      public static function getClothLightUrl(param1:uint) : String
      {
         return _clothLightURL + "light_" + param1 + ".swf";
      }
      
      public static function getClothCircleUrl(param1:uint) : String
      {
         var _loc2_:String = getClothLightUrl(param1);
         return _loc2_.replace(/light/g,"qq");
      }
      
      public static function getTransformMovieUrl(param1:uint) : String
      {
         return _transformURL + param1 + ".swf";
      }
      
      public static function getTransformClothUrl(param1:uint) : String
      {
         return getTransformMovieUrl(param1).replace(/movie\//,"swf/");
      }
      
      public static function getMailTemplateUrl(param1:uint) : String
      {
         return _mailTemplateURL + param1 + ".swf";
      }
      
      public static function getAppExtSwf(param1:String) : String
      {
         return "ext/com/robot/ext/Ext_" + param1 + ".swf";
      }
      
      public static function getNpcSwfPath(param1:String) : String
      {
         return _npcURL + param1 + ".swf";
      }
      
      public static function getResPath(param1:String) : String
      {
         return _resURL + param1;
      }
      
      public static function getMapPath(param1:uint) : String
      {
         return _resURL + "map/" + param1.toString() + ".swf";
      }
      
      public static function getNonoPath(param1:String) : String
      {
         return _resURL + "nono/" + param1 + ".swf";
      }
      
      public static function getRoomPath(param1:uint) : String
      {
         return _resURL + "room/" + param1.toString() + ".swf";
      }
      
      public static function getPetSwfPath(param1:uint) : String
      {
         return _resURL + (param1 > 500 ? "groupFightResource/pet/" : "pet/swf/") + param1.toString() + ".swf";
      }
      
      public static function getFlyPetSwfPath(param1:uint) : String
      {
         return _resURL + "groupFightResource/flyPet/" + param1.toString() + ".swf";
      }
      
      public static function getAppModule(param1:String) : String
      {
         return _moduleURL + param1 + ".swf";
      }
      
      public static function getTaskModule(param1:String) : String
      {
         return _taskModuleURL + param1 + ".swf";
      }
      
      public static function getBookModule(param1:String) : String
      {
         return _bookModuleURL + param1 + ".swf";
      }
      
      public static function getGameModule(param1:String) : String
      {
         return _gameModuleURL + param1 + ".swf";
      }
      
      public static function getHelpModule(param1:String) : String
      {
         return _helpModuleURL + param1 + ".swf";
      }
      
      public static function getTaskItemIcon(param1:String) : String
      {
         return _taskItemIconURL + param1 + ".swf";
      }
      
      public static function getFitmentIcon(param1:uint) : String
      {
         return _resURL + "fitment/icon/" + param1.toString() + ".swf";
      }
      
      public static function getFitmentItem(param1:uint) : String
      {
         return _resURL + "fitment/item/" + param1.toString() + ".swf";
      }
      
      public static function getArmIcon(param1:uint) : String
      {
         return _resURL + "arm/icon/" + param1.toString() + ".swf";
      }
      
      public static function getArmPrev(param1:String) : String
      {
         return _resURL + "arm/prev/" + param1.toString() + ".swf";
      }
      
      public static function getArmItem(param1:String) : String
      {
         return _resURL + "arm/item/" + param1.toString() + ".swf";
      }
      
      public static function getAppRes(param1:String) : String
      {
         return _resURL + "forApp/" + param1 + ".swf";
      }
      
      public static function getFullMovie(param1:String) : String
      {
         return _resURL + "bounsMovie/" + param1 + ".swf";
      }
      
      public static function getModule(param1:String) : String
      {
         return "module/com/robot/module/" + param1 + ".swf";
      }
      
      public static function getMapSound(param1:String) : String
      {
         if(param1 == "")
         {
            return "";
         }
         return _resURL + "map/sound/" + param1 + ".mp3";
      }
      
      public static function get httpURL() : String
      {
         return clientXML.ipConfig.http.@url;
      }
      
      public static function get SUB_SERVER_IP() : String
      {
         return clientXML.ipConfig.SubServer.@ip;
      }
      
      public static function get SUB_SERVER_PORT() : uint
      {
         return uint(clientXML.ipConfig.SubServer.@port);
      }
      
      public static function get EMAIL_IP() : String
      {
         return clientXML.ipConfig.Email.@ip;
      }
      
      public static function get EMAIL_PORT() : uint
      {
         return uint(clientXML.ipConfig.Email.@port);
      }
      
      public static function get ID_IP() : String
      {
         return clientXML.ipConfig.DirSer.@ip;
      }
      
      public static function get ID_PORT() : uint
      {
         return uint(clientXML.ipConfig.DirSer.@port);
      }
      
      public static function get GUEST_IP() : String
      {
         return clientXML.ipConfig.Visitor.@ip;
      }
      
      public static function get GUEST_PORT() : uint
      {
         return uint(clientXML.ipConfig.Visitor.@port);
      }
      
      public static function get REGIST_IP() : String
      {
         return clientXML.ipConfig.RegistSer.@ip;
      }
      
      public static function get REGIST_PORT() : uint
      {
         return uint(clientXML.ipConfig.RegistSer.@port);
      }
      
      public static function get maxPeople() : uint
      {
         return uint(clientXML.ServerList.@max);
      }
      
      public static function get newsVersion() : uint
      {
         return uint(clientXML.newsversion);
      }
      
      public static function get dailyTask() : uint
      {
         return uint(clientXML.dailyTask);
      }
      
      public static function get superNoNo() : uint
      {
         return uint(clientXML.superNoNo);
      }
      
      public static function get regVersion() : String
      {
         return clientXML.regversion;
      }
      
      public static function get uiVersion() : String
      {
         return clientXML.uiversion;
      }
      
      public static function get fightVersion() : String
      {
         return clientXML.fightVersion;
      }
   }
}

