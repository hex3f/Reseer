package com.robot.core.net
{
   import com.robot.core.manager.MapManager;
   import flash.events.Event;
   import org.taomee.net.SocketDispatcher;
   import org.taomee.net.SocketImpl;
   
   public class SocketConnection
   {
      
      private static var _mainSocket:SocketImpl;
      
      private static var _roomSocket:SocketImpl;
      
      public function SocketConnection()
      {
         super();
      }
      
      public static function get mainSocket() : SocketImpl
      {
         if(_mainSocket == null)
         {
            _mainSocket = new SocketImpl();
         }
         return _mainSocket;
      }
      
      public static function get roomSocket() : SocketImpl
      {
         if(_roomSocket == null)
         {
            _roomSocket = new SocketImpl();
         }
         return _roomSocket;
      }
      
      public static function addCmdListener(param1:uint, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         SocketDispatcher.getInstance().addEventListener(param1.toString(),param2,param3,param4,param5);
      }
      
      public static function removeCmdListener(param1:uint, param2:Function, param3:Boolean = false) : void
      {
         SocketDispatcher.getInstance().removeEventListener(param1.toString(),param2,param3);
      }
      
      public static function dispatchCmd(param1:Event) : void
      {
         SocketDispatcher.getInstance().dispatchEvent(param1);
      }
      
      public static function hasCmdListener(param1:uint) : Boolean
      {
         return SocketDispatcher.getInstance().hasEventListener(param1.toString());
      }
      
      public static function willTriggerCmd(param1:uint) : Boolean
      {
         return SocketDispatcher.getInstance().willTrigger(param1.toString());
      }
      
      public static function send(param1:uint, ... rest) : void
      {
         if(MapManager.type == ConnectionType.MAIN)
         {
            if(!mainSocket.connected)
            {
               mainSocket.dispatchEvent(new Event(Event.CLOSE));
            }
            mainSocket.send(param1,rest);
         }
         else if(MapManager.type == ConnectionType.ROOM)
         {
            roomSocket.send(param1,rest);
         }
      }
      
      internal static function send_2(param1:uint, param2:Array) : void
      {
         if(MapManager.type == ConnectionType.MAIN)
         {
            if(!mainSocket.connected)
            {
               mainSocket.dispatchEvent(new Event(Event.CLOSE));
            }
            mainSocket.send(param1,param2);
         }
         else if(MapManager.type == ConnectionType.ROOM)
         {
            roomSocket.send(param1,param2);
         }
      }
   }
}

