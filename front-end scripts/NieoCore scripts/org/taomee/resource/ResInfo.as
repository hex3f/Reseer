package org.taomee.resource
{
   public class ResInfo
   {
      
      public var level:int;
      
      public var nameList:Array = [];
      
      public var name:String = "";
      
      public var url:String;
      
      public var isLoading:Boolean = false;
      
      public var isCache:Boolean;
      
      public var eventList:Array = [];
      
      public function ResInfo()
      {
         super();
      }
   }
}

