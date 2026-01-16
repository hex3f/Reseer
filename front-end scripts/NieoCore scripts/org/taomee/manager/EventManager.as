package org.taomee.manager
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class EventManager
   {
      
      private static var instance:EventDispatcher;
      
      private static var isSingle:Boolean = false;
      
      public function EventManager()
      {
         super();
         if(!isSingle)
         {
            throw new Error("EventManager为单例模式，不能直接创建");
         }
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         getInstance().dispatchEvent(param1);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(instance == null)
         {
            isSingle = true;
            instance = new EventDispatcher();
         }
         isSingle = false;
         return instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
   }
}

