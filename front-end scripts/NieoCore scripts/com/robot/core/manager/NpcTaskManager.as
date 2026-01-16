package com.robot.core.manager
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class NpcTaskManager
   {
      
      private static var instance:EventDispatcher;
      
      private static var isSingle:Boolean = false;
      
      public function NpcTaskManager()
      {
         super();
         if(!isSingle)
         {
            throw new Error("NpcTaskManager为单例模式，不能直接创建");
         }
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
      
      public static function addTaskListener(param1:uint, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1.toString(),param2,param3,param4,param5);
      }
      
      public static function removeTaskListener(param1:uint, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1.toString(),param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            getInstance().dispatchEvent(param1);
         }
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
   }
}

