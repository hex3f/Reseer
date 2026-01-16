package
{
   import com.taomee.utils.VLU;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class DLLLoader extends EventDispatcher
   {
      
      private static var beanData:XMLList;
      
      public static const DLL_OVER:String = "dllOver";
      
      private static const XML_PATH:String = "config/dll.xml";
      
      private static const EXT_NODE_NAME:String = "ext";
      
      private static const BEAN_NODE_NAME:String = "Bean";
      
      public static const array:Array = [];
      
      private var dllArray:Array;
      
      private var stream:URLStream;
      
      private var loader:Loader;
      
      public var loadingMC:MovieClip;
      
      private var timer:Timer;
      
      public function DLLLoader()
      {
         super();
         this.loadingMC = new firstLoading();
         var num:uint = Math.floor(Math.random() * array.length);
         this.loadingMC["tip_txt"].text = array[num];
         this.timer = new Timer(2000);
         this.timer.addEventListener(TimerEvent.TIMER,this.changeTip);
         this.timer.start();
         this.dllArray = [];
         this.stream = new URLStream();
         this.stream.addEventListener(Event.COMPLETE,this._onComplete);
         this.stream.addEventListener(ProgressEvent.PROGRESS,this.progressHandler);
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this._loaderOver);
      }
      
      public static function parseStr(str:String) : void
      {
         var i:XML = null;
         var xml:XML = XML(str);
         for each(i in xml.loading.list)
         {
            array.push(i.@str);
         }
      }
      
      public static function getBeanXML() : XMLList
      {
         return beanData;
      }
      
      private function changeTip(event:TimerEvent) : void
      {
         var num:uint = Math.floor(Math.random() * array.length);
         this.loadingMC["tip_txt"].text = array[num];
      }
      
      public function doLoad() : void
      {
         var urlloader:URLLoader = new URLLoader();
         urlloader.addEventListener(Event.COMPLETE,this.xmlCompleteHandler);
         urlloader.addEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         urlloader.load(new URLRequest(XML_PATH + "?" + Math.random()));
      }
      
      private function xmlCompleteHandler(event:Event) : void
      {
         var i:XML = null;
         var _name:String = null;
         var _path:String = null;
         var _ver:String = null;
         URLLoader(event.currentTarget).removeEventListener(Event.COMPLETE,this.xmlCompleteHandler);
         URLLoader(event.currentTarget).removeEventListener(IOErrorEvent.IO_ERROR,this.errorHandler);
         var xmlData:XML = new XML(event.target.data);
         beanData = xmlData[BEAN_NODE_NAME];
         for each(i in xmlData[EXT_NODE_NAME].elements())
         {
            _name = i.@name;
            _path = i.@path;
            _ver = i.@ver;
            this.dllArray.push({
               "name":_name,
               "path":_path,
               "ver":_ver
            });
         }
         this.beginLoad();
      }
      
      private function errorHandler(event:IOErrorEvent) : void
      {
         trace("dll配置文件出错！！！！");
      }
      
      private function beginLoad() : void
      {
         if(this.dllArray.length > 0)
         {
            this.stream.load(VLU.getURLRequest(this.dllArray[0]["path"]));
            trace("加载DLL文件：",VLU.getURLRequest(this.dllArray[0]["path"]).url);
         }
         else
         {
            this.stream.removeEventListener(Event.COMPLETE,this._onComplete);
            this.stream.removeEventListener(ProgressEvent.PROGRESS,this.progressHandler);
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this._loaderOver);
            this.loader = null;
            this.stream = null;
            dispatchEvent(new Event(DLL_OVER));
            this.loadingMC.parent.removeChild(this.loadingMC);
            this.loadingMC = null;
            this.timer.stop();
            this.timer.removeEventListener(TimerEvent.TIMER,this.changeTip);
            this.timer = null;
         }
      }
      
      private function progressHandler(event:ProgressEvent) : void
      {
         var total:Number = event.bytesTotal;
         var loaded:Number = event.bytesLoaded;
         var percent:Number = Math.floor(loaded / total * 100);
         this.loadingMC["perNum"].text = percent + "%";
         this.loadingMC["content_txt"].text = "加载" + this.dllArray[0]["name"];
         this.loadingMC["loadingBar"].gotoAndStop(percent);
      }
      
      private function _onComplete(event:Event) : void
      {
         var byteArray:ByteArray = new ByteArray();
         if(Client.SERVER_XML == "config/Server.xml")
         {
            this.stream.readBytes(new ByteArray(),0,7);
         }
         this.stream.readBytes(byteArray);
         if(Client.SERVER_XML == "config/Server.xml")
         {
            byteArray.uncompress();
         }
         this.stream.close();
         this.loader.loadBytes(byteArray,new LoaderContext(false,ApplicationDomain.currentDomain));
      }
      
      private function _loaderOver(e:Event) : void
      {
         this.dllArray.shift();
         this.beginLoad();
      }
   }
}

