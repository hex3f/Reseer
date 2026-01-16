package com.robot.core.net
{
   import flash.events.EventDispatcher;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   [Event(name="complete",type="org.taomee.events.SocketEvent")]
   public class SocketLoader extends EventDispatcher
   {
      
      private static var _map:HashMap = new HashMap();
      
      public var extData:Object;
      
      private var _cmdID:uint;
      
      public function SocketLoader(param1:uint)
      {
         var _loc2_:Array = null;
         super();
         this._cmdID = param1;
         if(Boolean(this._cmdID))
         {
            _loc2_ = _map.getValue(this._cmdID);
            if(_loc2_ == null)
            {
               _loc2_ = [];
               _map.add(this._cmdID,_loc2_);
            }
            _loc2_.push(this);
         }
      }
      
      private static function onEvent(param1:SocketEvent) : void
      {
         var _loc2_:SocketLoader = null;
         var _loc3_:Array = _map.getValue(param1.headInfo.cmdID);
         if(Boolean(_loc3_))
         {
            _loc2_ = _loc3_.shift() as SocketLoader;
            if(_loc3_.length == 0)
            {
               _map.remove(param1.headInfo.cmdID);
               SocketConnection.removeCmdListener(param1.headInfo.cmdID,onEvent);
            }
            if(Boolean(_loc2_))
            {
               _loc2_.dispatchEvent(new SocketEvent(SocketEvent.COMPLETE,param1.headInfo,param1.data));
            }
         }
      }
      
      public function get cmdID() : uint
      {
         return this._cmdID;
      }
      
      public function load(... rest) : void
      {
         if(this._cmdID == 0)
         {
            throw new Error("命令ID不能为0");
         }
         SocketConnection.addCmdListener(this._cmdID,onEvent);
         SocketConnection.send_2(this._cmdID,rest);
      }
      
      public function canel() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(Boolean(this._cmdID))
         {
            _loc1_ = _map.getValue(this._cmdID);
            if(Boolean(_loc1_))
            {
               _loc2_ = _loc1_.indexOf(this);
               if(_loc2_ != -1)
               {
                  _loc1_.splice(_loc2_,1);
                  if(_loc1_.length == 0)
                  {
                     _map.remove(this._cmdID);
                     SocketConnection.removeCmdListener(this._cmdID,onEvent);
                  }
               }
            }
         }
      }
      
      public function destroy() : void
      {
         this.canel();
         this.extData = null;
      }
   }
}

