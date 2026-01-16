package com.taomee.pandaVersion
{
   import com.common.byteLoader.ByteLoader;
   import com.common.byteLoader.ByteLoaderEvent;
   import com.common.util.LoaderUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class PVM_Loader extends EventDispatcher implements IPVM_Loader
   {
      
      private var _auoLoadBody:Boolean = false;
      
      private var hasHeaderloaded:Boolean = false;
      
      private var hasReload:Boolean = false;
      
      private var _fileURL:String;
      
      private var _newURL:String;
      
      private var _headerFileDic:Dictionary = new Dictionary();
      
      private var _versionNameSpace:String;
      
      private var _HeaderCount:uint;
      
      private var _lastAmendTime:uint;
      
      private var fileLoader:ByteLoader;
      
      public var BC_List:Object;
      
      public function PVM_Loader(versionNameSpace:String, auoLoadBody:Boolean = false)
      {
         super();
         _versionNameSpace = versionNameSpace;
         _auoLoadBody = auoLoadBody;
      }
      
      private function _ioErrorFun(E:Event) : void
      {
         dispatchEvent(new PVM_Event(PVM_Event.ON_LOAD_ERROR));
      }
      
      private function _checkAmendLoaded(E:ByteLoaderEvent) : void
      {
         var index:int = 0;
         if(fileLoader.bytesLoaded >= 6)
         {
            _lastAmendTime = fileLoader.readUnsignedInt();
            _HeaderCount = fileLoader.readShort();
            index = int(_fileURL.indexOf("?"));
            if(index > -1)
            {
               _newURL = _fileURL + "&" + _lastAmendTime;
            }
            else
            {
               _newURL = _fileURL + "?" + _lastAmendTime;
            }
            BC.removeEvent(this,fileLoader,ByteLoaderEvent.GET_BYTE_DATA,_checkAmendLoaded);
            dispatchEvent(new PVM_Event(PVM_Event.ON_HEADER_AMEND_LOADED));
            fileLoader.close();
            changeVersion_AotuReLoad();
         }
      }
      
      private function _onComplete(E:Event) : void
      {
         BC.removeEvent(this);
         if(!_auoLoadBody)
         {
            parseHeader();
         }
         var l2:ByteArray = new ByteArray();
         fileLoader.readBytes(l2);
         l2.position = 0;
         l2.uncompress();
         var l1:PVM = PVM.getInstance(_versionNameSpace);
         l1.flushBady(l2.readObject());
         dispatchEvent(new PVM_Event(PVM_Event.ON_LOADED));
      }
      
      private function _getDataBginFun(E:ByteLoaderEvent) : void
      {
         if(fileLoader.bytesTotal <= 6)
         {
            BC.removeEvent(this);
            throw "文件太小了.";
         }
         if(!hasReload)
         {
            BC.addEvent(this,fileLoader,ByteLoaderEvent.GET_BYTE_DATA,_checkAmendLoaded);
         }
         if(hasReload && !hasHeaderloaded)
         {
            BC.addEvent(this,fileLoader,ByteLoaderEvent.GET_BYTE_DATA,_checkHeaderLoaded);
         }
      }
      
      private function parseHeader() : void
      {
         _lastAmendTime = fileLoader.readUnsignedInt();
         _HeaderCount = fileLoader.readShort();
         for(var i:int = 0; i < _HeaderCount; i++)
         {
            _headerFileDic[fileLoader.readUTFBytes(20)] = fileLoader.readUnsignedInt();
         }
      }
      
      private function changeVersion_AotuReLoad() : void
      {
         hasReload = true;
         fileLoader.load(new URLRequest(_newURL));
      }
      
      private function _onTimeoutFun(E:ByteLoaderEvent) : void
      {
         fileLoader.reTry();
         dispatchEvent(new PVM_Event(PVM_Event.ON_LOAD_TIMEOUT));
      }
      
      private function _checkHeaderLoaded(E:ByteLoaderEvent) : void
      {
         var l1:PVM = null;
         if(fileLoader.bytesLoaded >= _HeaderCount * 24 + 6)
         {
            parseHeader();
            BC.removeEvent(this,fileLoader,ByteLoaderEvent.GET_BYTE_DATA,_checkHeaderLoaded);
            hasHeaderloaded = true;
            l1 = PVM.getInstance(_versionNameSpace);
            l1.flushHeader(_lastAmendTime,_headerFileDic);
            if(!_auoLoadBody)
            {
               fileLoader.close();
            }
            dispatchEvent(new PVM_Event(PVM_Event.ON_HEADER_LOADED));
         }
      }
      
      public function load(fileURL:String) : void
      {
         _fileURL = fileURL;
         fileLoader = new ByteLoader(true);
         LoaderUtil.addLoaderEvents(this,fileLoader,_onComplete,_ioErrorFun);
         LoaderUtil.addByteLoaderEvents(this,fileLoader,_onTimeoutFun,_getDataBginFun);
         var index:int = int(_fileURL.indexOf("?"));
         if(index > -1)
         {
            fileLoader.load(new URLRequest(_fileURL + "&" + int(Math.random() * 10000000)));
         }
         else
         {
            fileLoader.load(new URLRequest(_fileURL + "?" + int(Math.random() * 10000000)));
         }
         hasReload = false;
      }
      
      public function loadBody() : void
      {
         if(hasReload)
         {
            fileLoader.load(new URLRequest(_newURL));
            return;
         }
         throw "必须HEADER部分加载完成后才能对BODY进行加载.";
      }
      
      public function get byteLoader() : ByteLoader
      {
         return fileLoader;
      }
      
      public function close() : void
      {
         BC.removeEvent(this);
         fileLoader.close();
      }
   }
}

