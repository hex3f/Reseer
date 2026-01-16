package org.taomee.net
{
   import flash.events.EventDispatcher;
   
   public class SocketDispatcher
   {
      
      private static var _instance:EventDispatcher;
      
      public function SocketDispatcher()
      {
         super();
      }
      
      public static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
      }
   }
}

