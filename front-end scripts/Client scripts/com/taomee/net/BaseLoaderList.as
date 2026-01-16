package com.taomee.net
{
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   
   public class BaseLoaderList implements ILoaderList
   {
      
      private static var owner:BaseLoaderList;
      
      public static var HIGHEST_AND_CLOSE_OTHERS:uint = 1;
      
      public static var HIGH:uint = 2;
      
      public static var STANDARD:uint = 3;
      
      public static var LOW:uint = 4;
      
      public static var LOWEST:uint = 5;
      
      public static var Max_LoaderNum:uint = 10;
      
      public static var Status:uint = 0;
      
      private var PRI_Array:Array;
      
      private var high_Array:Array;
      
      private var lowest_Array:Array;
      
      public var BC_List:Object;
      
      private var low_Array:Array;
      
      private var standard_Array:Array;
      
      private var highest_Array:Array;
      
      public function BaseLoaderList()
      {
         super();
         owner = this;
         PRI_Array = new Array();
         highest_Array = new Array();
         high_Array = new Array();
         standard_Array = new Array();
         low_Array = new Array();
         lowest_Array = new Array();
      }
      
      public static function getInstance() : BaseLoaderList
      {
         if(owner != null)
         {
            return owner;
         }
         return new BaseLoaderList();
      }
      
      private function checkLoading() : void
      {
         var tempObj:Object = null;
         var Loader_Obj:* = undefined;
         if(Boolean(highest_Array.length))
         {
            Status = 3;
            while(Boolean(PRI_Array.length))
            {
               tempObj = PRI_Array.pop();
               Loader_Obj = tempObj.LoaderObj;
               if(!Boolean(Loader_Obj["close"]))
               {
                  throw Loader_Obj + "类中不存在close关闭方法";
               }
               try
               {
                  Loader_Obj.close();
               }
               catch(E:*)
               {
               }
            }
            tempObj = highest_Array.shift();
            moveToPRIList(tempObj.LoaderObj,tempObj.URL_Request,1);
         }
         else
         {
            checkPRIStatus();
            if(Status < 2)
            {
               if(Boolean(high_Array.length))
               {
                  tempObj = high_Array.shift();
                  moveToPRIList(tempObj.LoaderObj,tempObj.URL_Request,2);
               }
               else if(Boolean(standard_Array.length))
               {
                  tempObj = standard_Array.shift();
                  moveToPRIList(tempObj.LoaderObj,tempObj.URL_Request,3);
               }
               else if(Boolean(low_Array.length))
               {
                  tempObj = low_Array.shift();
                  moveToPRIList(tempObj.LoaderObj,tempObj.URL_Request,4);
               }
               else if(Status == 0 && Boolean(lowest_Array.length))
               {
                  tempObj = lowest_Array.shift();
                  moveToPRIList(tempObj.LoaderObj,tempObj.URL_Request,5);
               }
            }
         }
      }
      
      private function checkPRIStatus() : uint
      {
         var i:int = 0;
         if(Status != 3)
         {
            if(PRI_Array.length < Max_LoaderNum)
            {
               if(PRI_Array.length == 0)
               {
                  Status = 0;
               }
               else
               {
                  Status = 1;
               }
            }
            else
            {
               Status = 2;
               for(i = PRI_Array.length - 1; i > 0; i--)
               {
                  if(PRI_Array[i].PRI_Num == 5)
                  {
                     PRI_Array.splice(i,1);
                     Status = 1;
                     break;
                  }
               }
            }
         }
         return Status;
      }
      
      protected function moveToPRIList(_LoaderObj:*, _URLRequest:URLRequest, _PRI_Num:int) : void
      {
         var tempObj:Object = null;
         var Loader_Obj:* = undefined;
         var disLoader:* = undefined;
         tempObj = {
            "LoaderObj":_LoaderObj,
            "PRI_Num":_PRI_Num
         };
         PRI_Array.push(tempObj);
         Loader_Obj = _LoaderObj;
         if(Boolean(_LoaderObj as URLLoader))
         {
            disLoader = _LoaderObj;
         }
         else
         {
            disLoader = _LoaderObj.contentLoaderInfo;
         }
         BC.addEvent(this,disLoader,Event.INIT,function(E:Event):void
         {
            BC.removeEvent(owner,E.target);
            delItemForPRIList(tempObj);
            checkLoading();
         });
         BC.addEvent(this,disLoader,Event.CLOSE,function(E:Event):void
         {
            BC.removeEvent(owner,E.target);
            addItem(Loader_Obj,_URLRequest,_PRI_Num,true);
            delItemForPRIList(tempObj);
            checkLoading();
         });
         BC.addEvent(this,disLoader,IOErrorEvent.IO_ERROR,function(E:IOErrorEvent):void
         {
            BC.removeEvent(owner,E.target);
            delItemForPRIList(tempObj,true);
            checkLoading();
            var ER:* = getDefinitionByName("ER") as Class;
            ER.sendError(ER.Developer_JACK,BaseLoaderList,ER.ErrorType_Loader_IO_Error,E.text);
            if(E.text.indexOf("#2036") != -1)
            {
               throw E;
            }
         });
         BC.addEvent(this,disLoader,HTTPStatusEvent.HTTP_STATUS,function(E:HTTPStatusEvent):void
         {
            var ER:* = undefined;
            if(E.status >= 400)
            {
               ER = getDefinitionByName("ER") as Class;
               ER.sendError("&size=0&time=0",BaseLoaderList,ER.StatType_NetSpeed,"");
               throw E;
            }
         });
         Loader_Obj.load(_URLRequest);
         _LoaderObj = null;
      }
      
      private function delItemForPRIList(item:Object, hasError:Boolean = false) : void
      {
         var i:int = 0;
         if(item.PRI_Num == 1)
         {
            Status = 0;
         }
         for(i = 0; i < PRI_Array.length; i++)
         {
            if(PRI_Array[i] == item)
            {
               PRI_Array.splice(i,1);
               break;
            }
         }
         item.LoaderObj = null;
         if(hasError && item.PRI_Num == 1)
         {
            setTimeout(function():*
            {
               throw new Error("高优先权加载项加载失败！");
            },100);
         }
      }
      
      public function addItem(_LoaderObj:*, _URLRequest:URLRequest, PRI_Num:int = 3, beforeArrayBool:Boolean = false) : void
      {
         var ErrorStr:String = null;
         if(!_LoaderObj)
         {
            throw new Error("添加到BaseLoaderList出错,加载器为空!").getStackTrace();
         }
         if(beforeArrayBool)
         {
            switch(PRI_Num)
            {
               case 1:
                  highest_Array.unshift({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 2:
                  high_Array.unshift({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 3:
                  standard_Array.unshift({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 4:
                  low_Array.unshift({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 5:
                  lowest_Array.unshift({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
            }
         }
         else
         {
            switch(PRI_Num)
            {
               case 1:
                  highest_Array.push({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 2:
                  high_Array.push({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 3:
                  standard_Array.push({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 4:
                  low_Array.push({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
                  break;
               case 5:
                  lowest_Array.push({
                     "LoaderObj":_LoaderObj,
                     "URL_Request":_URLRequest
                  });
            }
         }
         checkLoading();
      }
   }
}

