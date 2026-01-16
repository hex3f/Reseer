package com.taomee.utils
{
   import com.taomee.net.BaseLoaderList;
   import com.taomee.pandaVersion.PVM;
   import flash.net.URLRequest;
   
   public final class VLU
   {
      
      public function VLU()
      {
         super();
      }
      
      public static function getURLRequest(url:String = null, nameSpace:String = "all", loader:* = null, PRILevel:int = 3, isBefore:Boolean = false, AlwaysIsLatest:Boolean = false) : URLRequest
      {
         var loaderList:* = undefined;
         var _AlwaysIsLatest:Boolean = AlwaysIsLatest;
         var _nameSpace:String = nameSpace;
         if(Boolean(url))
         {
            url = PVM.getURL(url,_AlwaysIsLatest,_nameSpace);
         }
         var urlRequest:URLRequest = new URLRequest(url);
         if(loader)
         {
            loaderList = BaseLoaderList.getInstance();
            loaderList.addItem(loader,urlRequest,PRILevel,isBefore);
         }
         return urlRequest;
      }
   }
}

