package com.taomee.pandaVersion
{
   import flash.display.DisplayObjectContainer;
   import flash.utils.Dictionary;
   
   public class PVM
   {
      
      public static var ALL_VERSION:String = "all";
      
      public static var isOnline:Boolean = true;
      
      private static var pvmDic:Dictionary = new Dictionary(true);
      
      public var currentNameSpace:String;
      
      private var _lastAmendTime:uint;
      
      private var _headerFileDic:Dictionary;
      
      private var _bodyObj:Object;
      
      public function PVM(nameSpace:String)
      {
         super();
         currentNameSpace = nameSpace;
         pvmDic[nameSpace] = this;
      }
      
      public static function getURL(url:String, hasRandom:Boolean = false, nameSpace:String = "all") : String
      {
         var hasQuestString:Boolean = false;
         var QuestString:String = "";
         var version:String = "";
         var varsArray:Array = url.split("?");
         if(varsArray.length > 1)
         {
            QuestString = varsArray[1];
            url = varsArray[0];
            hasQuestString = true;
         }
         version = String(PVM.getInstance(nameSpace).getAmendValue(url).toString(36));
         if(isOnline)
         {
            if(version != "0")
            {
               if(hasRandom)
               {
                  if(hasQuestString)
                  {
                     url = url + "?" + QuestString + "&" + version + "&" + Math.round(Math.random() * 1000);
                  }
                  else
                  {
                     url = url + "?" + version + "&" + Math.round(Math.random() * 1000);
                  }
               }
               else if(hasQuestString)
               {
                  url = url + "?" + QuestString + "&" + version;
               }
               else
               {
                  url = url + "?" + version;
               }
            }
            else if(hasRandom)
            {
               if(hasQuestString)
               {
                  url = url + "?" + QuestString + "&" + Math.round(Math.random() * 1000);
               }
               else
               {
                  url = url + "?" + Math.round(Math.random() * 1000);
               }
            }
            else if(hasQuestString)
            {
               url = url + "?" + QuestString;
            }
            else
            {
               url = url;
            }
         }
         else if(hasRandom)
         {
            if(hasQuestString)
            {
               url = url + "?" + QuestString + "&" + Math.round(Math.random() * 1000);
            }
            else
            {
               url = url + "?" + Math.round(Math.random() * 1000);
            }
         }
         else if(hasQuestString)
         {
            url = url + "?" + QuestString;
         }
         else
         {
            url = url;
         }
         trace("[URL]",url,"-",version);
         return url;
      }
      
      public static function getInstance(nameSpace:String = "all") : PVM
      {
         return Boolean(pvmDic[nameSpace]) ? pvmDic[nameSpace] : new PVM(nameSpace);
      }
      
      public function checkIsOnline(stageMC:DisplayObjectContainer) : void
      {
         isOnline = stageMC.loaderInfo.url.indexOf("http:") > -1 ? true : false;
      }
      
      public function get lastAmendDate() : Date
      {
         return new Date(_lastAmendTime * 1000);
      }
      
      public function get lastAmendValue() : Number
      {
         return _lastAmendTime * 1000;
      }
      
      public function flushHeader(lastAmendTime:*, headerFileDic:*) : void
      {
         _lastAmendTime = lastAmendTime;
         _headerFileDic = headerFileDic;
      }
      
      public function getAmendValue(relativePath:String) : Number
      {
         var ta:Array = null;
         var folderPath:String = null;
         var fileName:String = null;
         var fid:uint = 0;
         var res:Number = 0;
         if(Boolean(_headerFileDic))
         {
            res = Number(_headerFileDic[relativePath]);
         }
         if(!res && Boolean(_bodyObj))
         {
            ta = relativePath.split("/");
            folderPath = ta.slice(0,ta.length - 1).join("/");
            fileName = String(ta[ta.length - 1]).split(".")[0];
            fid = uint(_bodyObj.folderObj[folderPath]);
            res = Number(_bodyObj.fileObj[fid + ":" + fileName]);
         }
         if(isNaN(res))
         {
            res = 0;
         }
         else
         {
            res *= 1000;
         }
         return res;
      }
      
      public function flushBady(bodyObj:*) : void
      {
         _bodyObj = bodyObj;
      }
      
      public function getAmendDate(relativePath:String) : Date
      {
         return new Date(getAmendValue(relativePath));
      }
   }
}

import com.taomee.utils.VLU;

VLU;

