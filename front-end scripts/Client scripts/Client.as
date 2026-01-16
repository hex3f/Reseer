package
{
   import com.common.util.LoaderUtil;
   import com.taomee.pandaVersion.IPVM_Loader;
   import com.taomee.pandaVersion.PVM;
   import com.taomee.pandaVersion.PVM_Event;
   import com.taomee.pandaVersion.PVM_Loader;
   import com.taomee.utils.VLU;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLStream;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.Timer;
   import flash.utils.clearTimeout;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   
   [SWF(width="960",height="560",frameRate="24")]
   public class Client extends Sprite
   {
      
      public static const LOGIN_SUCCESS:String = "loginSuccess";
      
      public static const SERVER_XML:String = "config/ServerR.xml";
      
      private static var RESOURCE_PATH:String = "resource/main_resource.swf";
      
      private static var LOGIN_PATH:String = "login/Login.swf";
      
      private var bgMC:MovieClip;
      
      private var loader:Loader;
      
      private var dllLoader:DLLLoader;
      
      private var xmlloader:URLStream;
      
      private var loadingMC:MovieClip;
      
      private const DOOR_XML:String = "config/doorConfig.xml";
      
      private const CHECK_URL:String = "http://10.1.1.240:1500/time";
      
      private var urlLoader:URLLoader;
      
      private var tineOut:uint;
      
      private var loadTime:int;
      
      private var size:uint;
      
      private var configXML:XML;
      
      private var updateXML:XML;
      
      private var timer:Timer;
      
      public var BC_List:Object;
      
      private var fileLoader:PVM_Loader;
      
      public function Client()
      {
         super();
         var bg:MovieClip = new mainBG();
         bg.cacheAsBitmap = true;
         addChildAt(bg,0);
         this.loadingMC = new firstLoading();
         this.timer = new Timer(2000);
         this.timer.addEventListener(TimerEvent.TIMER,this.changeTip);
         stage.stageFocusRect = false;
         stage.scaleMode = StageScaleMode.NO_SCALE;
         var contextMenu:ContextMenu = new ContextMenu();
         this.contextMenu = contextMenu;
         var contextItem:ContextMenuItem = new ContextMenuItem("您的Flash播放器版本：" + Capabilities.version);
         contextMenu.hideBuiltInItems();
         contextMenu.customItems.push(contextItem);
         this.loadDorrXml();
      }
      
      private function loadDorrXml() : void
      {
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.onDoorXmlHandler);
         loader.load(new URLRequest(this.DOOR_XML + "?" + Math.random()));
      }
      
      private function onDoorXmlHandler(e:Event) : void
      {
         var xml:XML;
         var xmlL:XML;
         var urlRe:URLRequest = null;
         var loader:URLLoader = e.target as URLLoader;
         loader.removeEventListener(Event.COMPLETE,this.onDoorXmlHandler);
         xml = new XML(loader.data);
         xmlL = xml.elements("time")[0] as XML;
         if(Boolean(uint(xmlL.@isOpen)))
         {
            this.start();
         }
         else
         {
            urlRe = new URLRequest(this.CHECK_URL);
            this.urlLoader = new URLLoader();
            this.urlLoader.addEventListener(Event.COMPLETE,this.onComHandler);
            this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onIoHandler);
            this.urlLoader.load(urlRe);
            this.tineOut = setTimeout(function():void
            {
               clearTimeout(tineOut);
               urlLoader.removeEventListener(Event.COMPLETE,onComHandler);
               urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIoHandler);
               urlLoader = null;
               urlRe = null;
               start();
            },5000);
         }
      }
      
      private function onIoHandler(e:IOErrorEvent) : void
      {
         clearTimeout(this.tineOut);
         this.urlLoader.removeEventListener(Event.COMPLETE,this.onComHandler);
         this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onIoHandler);
         this.urlLoader = null;
         this.start();
      }
      
      private function onComHandler(e:Event) : void
      {
         clearTimeout(this.tineOut);
         this.urlLoader.removeEventListener(Event.COMPLETE,this.onComHandler);
         this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onIoHandler);
         var b1:int = int(this.urlLoader.data);
         var date:Date = new Date(b1 * 1000);
         if(date.getHours() >= 0 && date.getHours() <= 5)
         {
            navigateToURL(new URLRequest("http://www.51seer.com/index_close.html"),"_self");
         }
         else
         {
            this.start();
         }
         this.urlLoader = null;
      }
      
      private function start() : void
      {
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadResource);
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.failResource);
         this.loader.load(new URLRequest(RESOURCE_PATH));
      }
      
      private function changeTip(event:TimerEvent) : void
      {
         var num:uint = Math.floor(Math.random() * DLLLoader.array.length);
         this.loadingMC["tip_txt"].text = DLLLoader.array[num];
      }
      
      private function onLoadResource(event:Event) : void
      {
         this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadResource);
         this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.failResource);
         this.loadXMLResource();
      }
      
      private function init() : void
      {
         this.dllLoader = new DLLLoader();
         this.stage.addChild(this.dllLoader.loadingMC);
         this.dllLoader.addEventListener(DLLLoader.DLL_OVER,this.onDLLComplete);
         this.dllLoader.doLoad();
      }
      
      private function onDLLComplete(event:Event) : void
      {
         trace("DLL加载完成");
         this.dllLoader.removeEventListener(DLLLoader.DLL_OVER,this.onDLLComplete);
         this.dllLoader = null;
         var clientConfig:* = getDefinitionByName("com.robot.core.config.ClientConfig");
         clientConfig.setup(this.configXML);
         var updateConfig:* = getDefinitionByName("com.robot.core.config.UpdateConfig");
         updateConfig.setup(this.updateXML);
         var cls:* = getDefinitionByName("com.robot.core.manager.LoadingManager");
         cls.setup(this.loader);
         this.loadReg();
         var param:Object = this.loaderInfo.parameters;
         var mainManager:* = getDefinitionByName("com.robot.core.manager.MainManager");
         mainManager.CHANNEL = uint(param["channel"]);
      }
      
      private function loadReg() : void
      {
         var clientConfig:* = getDefinitionByName("com.robot.core.config.ClientConfig");
         this.stage.addChild(this.loadingMC);
         this.loadingMC["content_txt"].text = "正在加载登陆界面";
         var loginLoader:Loader = new Loader();
         loginLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadReg);
         loginLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.regProgress);
         loginLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.failResource);
         loginLoader.load(VLU.getURLRequest(LOGIN_PATH));
         trace("加载登陆界面：",LOGIN_PATH);
      }
      
      private function loadXMLResource() : void
      {
         trace("加载Server.xml");
         this.xmlloader = new URLStream();
         this.xmlloader.addEventListener(Event.COMPLETE,this.onServerComplete);
         this.xmlloader.addEventListener(IOErrorEvent.IO_ERROR,this.onServerError);
         this.xmlloader.load(new URLRequest(SERVER_XML + "?" + Math.random()));
      }
      
      private function onServerComplete(event:Event) : void
      {
         this.xmlloader.removeEventListener(Event.COMPLETE,this.onServerComplete);
         this.xmlloader.removeEventListener(IOErrorEvent.IO_ERROR,this.onServerError);
         var by:ByteArray = new ByteArray();
         this.xmlloader.readBytes(by);
         if(SERVER_XML == "config/Server.xml")
         {
            by.uncompress();
         }
         var array:Array = by.readUTFBytes(by.bytesAvailable).split("****");
         this.configXML = XML(array[0]);
         this.updateXML = XML(array[1]);
         DLLLoader.parseStr(array[1]);
         this.timer.start();
         var num:uint = Math.floor(Math.random() * DLLLoader.array.length);
         this.loadingMC["tip_txt"].text = DLLLoader.array[num];
         this.initPVM();
         this.loadTime = getTimer();
      }
      
      private function onLoadReg(e:Event) : void
      {
         var urllloader:URLLoader;
         var loaderInfo:LoaderInfo = e.target as LoaderInfo;
         loaderInfo.removeEventListener(Event.COMPLETE,this.onLoadResource);
         loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.failResource);
         loaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.regProgress);
         loaderInfo.content.addEventListener(LOGIN_SUCCESS,this.onLoginSuccess);
         addChild(loaderInfo.content);
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.changeTip);
         this.timer = null;
         this.loadingMC.parent.removeChild(this.loadingMC);
         this.loadingMC = null;
         this.loadTime = getTimer() - this.loadTime;
         urllloader = new URLLoader();
         urllloader.addEventListener(Event.COMPLETE,this.onGetIP);
         urllloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function():void
         {
            trace("get ip SecurityErrorEvent");
         });
         urllloader.addEventListener(IOErrorEvent.IO_ERROR,this.onIPError);
         urllloader.load(new URLRequest("http://www.51seer.com/ip"));
      }
      
      private function regProgress(event:ProgressEvent) : void
      {
         var total:Number = event.bytesTotal;
         var loaded:Number = event.bytesLoaded;
         this.size = total;
         var percent:Number = Math.floor(loaded / total * 100);
         this.loadingMC["perNum"].text = percent + "%";
         this.loadingMC["loadingBar"].gotoAndStop(percent);
      }
      
      private function onLoginSuccess(event:Event) : void
      {
         var s:* = event.target;
         s.removeEventListener(LOGIN_SUCCESS,this.onLoginSuccess);
         var ip:String = s.svrObj.ip;
         var port:uint = uint(s.svrObj.port);
         var userID:uint = uint(s.svrObj.userID);
         var session:ByteArray = s.svrObj.session;
         var friendData:IDataInput = s.svrObj.friendData;
         var bSavaMi:Boolean = Boolean(s.svrObj.bSavaMi);
         var pwd:String = s.svrObj.pwd;
         var meClass:Class = getDefinitionByName("com.robot.app.MainEntry") as Class;
         var mainEntry:* = new meClass();
         mainEntry.setup(this,ip,port,userID,session,friendData,bSavaMi,pwd);
         s.parent.removeChild(s);
      }
      
      private function failResource(event:IOErrorEvent) : void
      {
         var urllloader:URLLoader = new URLLoader();
         urllloader.addEventListener(Event.COMPLETE,this.onGetIPByError);
         urllloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,function():void
         {
            trace("get ip SecurityErrorEvent");
         });
         urllloader.addEventListener(IOErrorEvent.IO_ERROR,this.onIPError);
         urllloader.load(new URLRequest("http://www.51seer.com/ip"));
         throw new Error("文件加载错误！");
      }
      
      private function onServerError(event:Event) : void
      {
         throw new Error("xml资源加载错误，请检查XML资源！");
      }
      
      public function removeBG() : void
      {
         removeChild(this.bgMC);
         this.bgMC = null;
      }
      
      private function onGetIP(event:Event) : void
      {
         var loader:URLLoader = event.currentTarget as URLLoader;
         var ip:String = loader.data;
         var urlloader:URLLoader = new URLLoader();
         var varobj:URLVariables = new URLVariables();
         varobj["ip"] = ip;
         varobj["size"] = this.size;
         varobj["time"] = this.loadTime;
         varobj["game"] = "seer";
         var r:URLRequest = new URLRequest("http://114.80.98.38/stat/ip_speed_stat.php");
         r.method = URLRequestMethod.POST;
         r.data = varobj;
      }
      
      private function onGetIPByError(event:Event) : void
      {
         var loader:URLLoader = event.currentTarget as URLLoader;
         var ip:String = loader.data;
         var urlloader:URLLoader = new URLLoader();
         var varobj:URLVariables = new URLVariables();
         varobj["ip"] = ip;
         varobj["size"] = 0;
         varobj["time"] = 0;
         varobj["game"] = "seer";
         var r:URLRequest = new URLRequest("http://114.80.98.38/stat/ip_speed_stat.php");
         r.method = URLRequestMethod.POST;
         r.data = varobj;
      }
      
      private function onIPError(e:IOErrorEvent) : void
      {
      }
      
      private function initPVM() : void
      {
         PVM.getInstance(PVM.ALL_VERSION).checkIsOnline(this.stage);
         this.fileLoader = new PVM_Loader(PVM.ALL_VERSION);
         this.fileLoader.addEventListener(PVM_Event.ON_HEADER_LOADED,this.onHeaderLoaded);
         this.fileLoader.load("version.swf");
      }
      
      private function onHeaderLoaded(E:PVM_Event) : void
      {
         this.fileLoader.removeEventListener(PVM_Event.ON_HEADER_LOADED,this.onHeaderLoaded);
         this.onHeaderFilesListLoaded_And_LoadBody();
      }
      
      private function onHeaderFilesListLoaded_And_LoadBody() : void
      {
         IPVM_Loader(this.fileLoader).loadBody();
         this.fileLoader.addEventListener(PVM_Event.ON_LOADED,this.onBodyLoaded);
         LoaderUtil.addLoaderEvents(this,this.fileLoader.byteLoader,null,null,null,this.progressHandler);
      }
      
      private function progressHandler(event:ProgressEvent) : void
      {
         var total:Number = event.bytesTotal;
         var loaded:Number = event.bytesLoaded;
         var percent:Number = Math.floor(loaded / total * 100);
         this.loadingMC["perNum"].text = percent + "%";
         this.loadingMC["tip_txt"].text = "加载赛尔号环境信息.";
         this.loadingMC["loadingBar"].gotoAndStop(percent);
      }
      
      private function onBodyLoaded(E:PVM_Event) : void
      {
         this.fileLoader.removeEventListener(PVM_Event.ON_LOADED,this.onBodyLoaded);
         this.init();
      }
   }
}

