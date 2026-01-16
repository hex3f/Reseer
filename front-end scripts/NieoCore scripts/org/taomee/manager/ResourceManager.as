package org.taomee.manager
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.utils.getQualifiedClassName;
   import org.taomee.ds.HashMap;
   import org.taomee.resource.ResInfo;
   import org.taomee.resource.ResLoader;
   import org.taomee.utils.ArrayUtil;
   
   public class ResourceManager
   {
      
      public static const RESOUCE_ERROR:String = "resourceError";
      
      public static const RESOUCE_REFLECT_ERROR:String = "resourceReflectError";
      
      public static const HIGHEST:int = 0;
      
      public static const HIGH:int = 1;
      
      public static const STANDARD:int = 2;
      
      public static const LOW:int = 3;
      
      public static const LOWEST:int = 4;
      
      public static var maxLpt:uint = 2;
      
      public static var maxCache:uint = 300;
      
      private static var _dataList:Array = [];
      
      private static var _loaderList:Array = [];
      
      private static var _cacheList:Array = [];
      
      private static var _cacheMultiList:Array = [];
      
      private static var _isStop:Boolean = false;
      
      public function ResourceManager()
      {
         super();
      }
      
      public static function play() : void
      {
         _isStop = false;
         nextLoad();
      }
      
      private static function cancelEmpl(param1:String, param2:Function = null) : void
      {
         var _loc3_:ResLoader = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         for each(_loc3_ in _loaderList)
         {
            if(_loc3_.resInfo.url == param1)
            {
               if(param2 != null)
               {
                  _loc6_ = int(_loc3_.resInfo.eventList.indexOf(param2));
                  if(_loc6_ == -1)
                  {
                     return;
                  }
                  _loc3_.resInfo.eventList.splice(_loc6_,1);
                  if(_loc3_.resInfo.eventList.length > 0)
                  {
                     return;
                  }
               }
               removeLoader(_loc3_);
               _loc4_ = int(_dataList.length);
               _loc5_ = 0;
               while(_loc5_ < _loc4_)
               {
                  if(_dataList[_loc5_].url == param1)
                  {
                     _dataList.splice(_loc5_,1);
                     break;
                  }
                  _loc5_++;
               }
               nextLoad();
               return;
            }
         }
      }
      
      public static function getResourceList(param1:String, param2:Function, param3:Array, param4:int = 3, param5:Boolean = true) : void
      {
         var _loc6_:Array = null;
         var _loc7_:Object = null;
         var _loc8_:HashMap = null;
         var _loc9_:String = null;
         var _loc10_:Class = null;
         var _loc11_:ResInfo = null;
         var _loc12_:ResInfo = null;
         var _loc13_:ResLoader = null;
         if(_cacheMultiList.length > 0)
         {
            _loc6_ = [];
            for each(_loc7_ in _cacheMultiList)
            {
               if(_loc7_.url == param1)
               {
                  _loc8_ = _loc7_.map;
                  for(_loc9_ in param3)
                  {
                     _loc10_ = _loc8_.getValue(_loc9_);
                     if(Boolean(_loc10_))
                     {
                        if(_loc10_ is BitmapData)
                        {
                           _loc6_.push(new Bitmap(_loc10_ as BitmapData));
                        }
                        else
                        {
                           _loc6_.push(new _loc10_());
                        }
                     }
                  }
                  break;
               }
            }
            if(_loc6_.length == param3.length)
            {
               param2(_loc6_);
               return;
            }
         }
         var _loc14_:Boolean = false;
         var _loc15_:int = int(_dataList.length);
         if(_loc15_ > 0)
         {
            for each(_loc11_ in _dataList)
            {
               if(_loc11_.url == param1)
               {
                  if(_loc11_.name == "")
                  {
                     _loc11_.eventList.push(param2);
                     _loc14_ = true;
                  }
                  break;
               }
            }
         }
         if(!_loc14_)
         {
            _loc12_ = new ResInfo();
            _loc12_.eventList.push(param2);
            _loc12_.isCache = param5;
            _loc12_.level = param4;
            _loc12_.url = param1;
            param3.sort();
            _loc12_.nameList = param3;
            _dataList.push(_loc12_);
            _dataList.sortOn("level",Array.NUMERIC);
            _loc13_ = getEmptyLoader(param4);
            if(Boolean(_loc13_))
            {
               _loc13_.load(_loc12_);
            }
         }
      }
      
      private static function getEmptyLoader(param1:int = 3) : ResLoader
      {
         var _loc2_:ResLoader = null;
         var _loc3_:int = int(_loaderList.length);
         if(_loc3_ < maxLpt)
         {
            _loc2_ = new ResLoader();
            _loc2_.addEventListener(Event.COMPLETE,onLoadComplete);
            _loc2_.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
            _loaderList.push(_loc2_);
            return _loc2_;
         }
         _loaderList.sortOn("level",Array.NUMERIC | Array.DESCENDING);
         _loc2_ = _loaderList[0] as ResLoader;
         if(param1 == HIGHEST)
         {
            _loc2_.close();
            return _loc2_;
         }
         if(param1 != LOWEST)
         {
            if(_loc2_.level == LOWEST)
            {
               _loc2_.close();
               return _loc2_;
            }
         }
         return null;
      }
      
      private static function onLoadComplete(param1:Event) : void
      {
         var resInfo:ResInfo = null;
         var cacheMap:HashMap = null;
         var e:Event = param1;
         resInfo = null;
         var bd:BitmapData = null;
         var d:Function = null;
         var cla:Class = null;
         var nlen:int = 0;
         var dd:Function = null;
         var outArr:Array = null;
         cacheMap = null;
         var nameList:Array = null;
         var resName:String = null;
         var hasURL:Boolean = false;
         var nl:Function = null;
         var n:Function = null;
         var resLoader:ResLoader = e.target as ResLoader;
         var loaderInfo:LoaderInfo = resLoader.loaderInfo;
         resInfo = resLoader.resInfo;
         var eventList:Array = resInfo.eventList;
         if(loaderInfo.content is Bitmap)
         {
            bd = (loaderInfo.content as Bitmap).bitmapData.clone();
            if(resInfo.isCache)
            {
               _cacheList.push({
                  "url":resInfo.url,
                  "res":bd
               });
            }
            for each(d in eventList)
            {
               d(new Bitmap(bd));
            }
         }
         else if(resInfo.name == "")
         {
            nlen = int(resInfo.nameList.length);
            if(nlen == 0)
            {
               cla = loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(loaderInfo.content)) as Class;
               if(resInfo.isCache)
               {
                  _cacheList.push({
                     "url":resInfo.url,
                     "res":cla
                  });
               }
               for each(dd in eventList)
               {
                  dd(new cla());
               }
            }
            else
            {
               outArr = [];
               cacheMap = new HashMap();
               nameList = resInfo.nameList;
               for each(resName in nameList)
               {
                  if(loaderInfo.applicationDomain.hasDefinition(resName))
                  {
                     cla = loaderInfo.applicationDomain.getDefinition(resName) as Class;
                     if(Boolean(cla))
                     {
                        cacheMap.add(resName,cla);
                        if(cla is BitmapData)
                        {
                           outArr.push(new Bitmap(cla as BitmapData));
                        }
                        else
                        {
                           outArr.push(new cla());
                        }
                     }
                  }
                  else
                  {
                     EventManager.dispatchEvent(new Event(RESOUCE_REFLECT_ERROR));
                  }
               }
               if(resInfo.isCache)
               {
                  hasURL = Boolean(_cacheMultiList.some(function(param1:Object, param2:int, param3:Array):Boolean
                  {
                     var cmap:* = undefined;
                     var item:Object = param1;
                     var index:int = param2;
                     var array:Array = param3;
                     cmap = undefined;
                     if(item.url == resInfo.url)
                     {
                        cmap = item.map;
                        cacheMap.each2(function(param1:*, param2:*):void
                        {
                           cmap.add(param1,param2);
                        });
                        return true;
                     }
                     return false;
                  }));
                  if(!hasURL)
                  {
                     _cacheMultiList.push({
                        "url":resInfo.url,
                        "map":cacheMap
                     });
                  }
               }
               else
               {
                  cacheMap = null;
               }
               if(outArr.length > 0)
               {
                  for each(nl in eventList)
                  {
                     nl(outArr);
                  }
               }
               if(_cacheMultiList.length > maxCache)
               {
                  _cacheMultiList.shift();
               }
            }
         }
         else
         {
            if(loaderInfo.applicationDomain.hasDefinition(resInfo.name))
            {
               cla = loaderInfo.applicationDomain.getDefinition(resInfo.name) as Class;
            }
            else
            {
               EventManager.dispatchEvent(new Event(RESOUCE_REFLECT_ERROR));
            }
            if(Boolean(cla))
            {
               if(resInfo.isCache)
               {
                  _cacheList.push({
                     "url":resInfo.url,
                     "res":cla
                  });
               }
               for each(n in eventList)
               {
                  n(new cla());
               }
            }
         }
         removeLoader(resLoader);
         if(_cacheList.length > maxCache)
         {
            _cacheList.shift();
         }
         ArrayUtil.removeValueFromArray(_dataList,resInfo);
         nextLoad();
      }
      
      public static function stop() : void
      {
         var _loc1_:ResLoader = null;
         _isStop = true;
         for each(_loc1_ in _loaderList)
         {
            if(_loc1_.level == LOWEST)
            {
               removeLoader(_loc1_);
            }
         }
      }
      
      public static function cancel(param1:String, param2:Function) : void
      {
         cancelEmpl(param1,param2);
      }
      
      public static function getResource(param1:String, param2:Function, param3:String = "item", param4:int = 3, param5:Boolean = true) : void
      {
         var isHas:Boolean = false;
         var url:String = param1;
         var event:Function = param2;
         var name:String = param3;
         var level:int = param4;
         var isCache:Boolean = param5;
         var n:Object = null;
         var resInfo:ResInfo = null;
         var resLoader:ResLoader = null;
         if(_cacheList.length > 0)
         {
            for each(n in _cacheList)
            {
               if(n.url == url)
               {
                  if(n.res is BitmapData)
                  {
                     event(new Bitmap(n.res as BitmapData));
                  }
                  else
                  {
                     event(new n.res());
                  }
                  return;
               }
            }
         }
         isHas = Boolean(_dataList.some(function(param1:ResInfo, param2:int, param3:Array):Boolean
         {
            if(param1.url == url)
            {
               param1.eventList.push(event);
               return true;
            }
            return false;
         }));
         if(!isHas)
         {
            resInfo = new ResInfo();
            resInfo.eventList.push(event);
            resInfo.isCache = isCache;
            resInfo.level = level;
            resInfo.url = url;
            resInfo.name = name;
            _dataList.push(resInfo);
            _dataList.sortOn("level",Array.NUMERIC);
            resLoader = getEmptyLoader(level);
            if(Boolean(resLoader))
            {
               resLoader.load(resInfo);
            }
         }
      }
      
      public static function cancelURL(param1:String) : void
      {
         cancelEmpl(param1);
      }
      
      public static function cancelAll() : void
      {
         var _loc1_:ResLoader = null;
         for each(_loc1_ in _loaderList)
         {
            removeLoader(_loc1_);
         }
         _loaderList = [];
         _dataList = [];
      }
      
      private static function onIOError(param1:IOErrorEvent) : void
      {
         var _loc2_:ResLoader = param1.target as ResLoader;
         var _loc3_:ResInfo = _loc2_.resInfo;
         removeLoader(_loc2_);
         ArrayUtil.removeValueFromArray(_dataList,_loc3_);
         nextLoad();
         EventManager.dispatchEvent(new Event(RESOUCE_ERROR));
      }
      
      public static function addBef(param1:String, param2:String = "item", param3:Boolean = true) : void
      {
         var _loc4_:ResInfo = null;
         var _loc5_:ResInfo = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = int(_dataList.length);
         if(_loc7_ > 0)
         {
            for each(_loc4_ in _dataList)
            {
               if(_loc4_.url == param1)
               {
                  _loc6_ = true;
                  break;
               }
            }
         }
         if(!_loc6_)
         {
            _loc5_ = new ResInfo();
            _loc5_.isCache = param3;
            _loc5_.level = LOWEST;
            _loc5_.url = param1;
            _loc5_.name = param2;
            _dataList.push(_loc5_);
         }
      }
      
      private static function removeLoader(param1:ResLoader) : void
      {
         ArrayUtil.removeValueFromArray(_loaderList,param1);
         if(param1.isLoading)
         {
            param1.close();
         }
         param1.removeEventListener(Event.COMPLETE,onLoadComplete);
         param1.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
         param1.destroy();
         param1 = null;
      }
      
      private static function nextLoad() : void
      {
         var _loc1_:int = 0;
         var _loc2_:ResInfo = null;
         var _loc3_:ResLoader = null;
         if(_isStop)
         {
            return;
         }
         var _loc4_:int = int(_dataList.length);
         if(_loc4_ > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               _loc2_ = _dataList[_loc1_] as ResInfo;
               if(!_loc2_.isLoading)
               {
                  _loc3_ = getEmptyLoader();
                  if(Boolean(_loc3_))
                  {
                     _loc3_.load(_loc2_);
                  }
                  break;
               }
               _loc1_++;
            }
         }
      }
   }
}

