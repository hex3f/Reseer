package com.robot.core.event
{
   import flash.events.Event;
   import flash.net.URLLoader;
   
   public class XMLLoadEvent extends Event
   {
      
      public static var ON_SUCCESS:String = "onSuccess";
      
      public static var ERROR:String = "error";
      
      private var urlloader:URLLoader;
      
      private var _xml:XML;
      
      public function XMLLoadEvent(param1:String, param2:URLLoader, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.urlloader = param2;
      }
      
      public function getXML() : XML
      {
         return new XML(this.urlloader.data);
      }
   }
}

