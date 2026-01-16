package com.robot.app.sceneInteraction
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   public class RoomPetManager extends EventDispatcher
   {
      
      private static var _instance:RoomPetManager;
      
      private var _petMap:HashMap = new HashMap();
      
      private var _isget:Boolean;
      
      public function RoomPetManager()
      {
         super();
      }
      
      public static function getInstance() : RoomPetManager
      {
         if(_instance == null)
         {
            _instance = new RoomPetManager();
         }
         return _instance;
      }
      
      public static function destroy() : void
      {
         if(Boolean(_instance))
         {
            _instance.destroy();
            _instance = null;
         }
      }
      
      public function getShowList(param1:uint) : void
      {
         if(this._isget)
         {
            dispatchEvent(new PetEvent(PetEvent.ROOM_PET_LIST,0));
            return;
         }
         SocketConnection.addCmdListener(CommandID.PET_ROOM_LIST,this.onList);
         SocketConnection.addCmdListener(CommandID.PET_ROOM_SHOW,this.onList);
         SocketConnection.send(CommandID.PET_ROOM_LIST,param1);
      }
      
      public function getInfos() : Array
      {
         return this._petMap.getValues();
      }
      
      public function showOrHide(param1:PetListInfo, param2:Boolean) : void
      {
         var _loc3_:PetListInfo = null;
         if(param2)
         {
            if(this._petMap.length == 5)
            {
               Alarm.show("你已经有5个精灵在展示，再添加的话，精灵会觉得很拥挤哦");
               return;
            }
            this._petMap.add(param1.catchTime,param1);
         }
         else if(!this._petMap.remove(param1.catchTime))
         {
            return;
         }
         var _loc4_:Array = this._petMap.getValues();
         if(_loc4_.length == 0)
         {
            SocketConnection.send(CommandID.PET_ROOM_SHOW,0);
            return;
         }
         var _loc5_:ByteArray = new ByteArray();
         for each(_loc3_ in _loc4_)
         {
            _loc5_.writeUnsignedInt(_loc3_.catchTime);
            _loc5_.writeUnsignedInt(_loc3_.id);
         }
         SocketConnection.send(CommandID.PET_ROOM_SHOW,this._petMap.length,_loc5_);
      }
      
      public function removePet(param1:uint) : void
      {
         if(Boolean(this._petMap.remove(param1)))
         {
            dispatchEvent(new PetEvent(PetEvent.ROOM_PET_SHOW,0));
         }
      }
      
      public function contains(param1:uint) : Boolean
      {
         return this._petMap.containsKey(param1);
      }
      
      public function destroy() : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_ROOM_LIST,this.onList);
         SocketConnection.removeCmdListener(CommandID.PET_ROOM_SHOW,this.onList);
         this._petMap = null;
      }
      
      private function onList(param1:SocketEvent) : void
      {
         var _loc2_:PetListInfo = null;
         this._petMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new PetListInfo(_loc3_);
            this._petMap.add(_loc2_.catchTime,_loc2_);
            _loc5_++;
         }
         if(param1.headInfo.cmdID == CommandID.PET_ROOM_LIST)
         {
            this._isget = true;
            SocketConnection.removeCmdListener(CommandID.PET_ROOM_LIST,this.onList);
            dispatchEvent(new PetEvent(PetEvent.ROOM_PET_LIST,0));
         }
         else
         {
            dispatchEvent(new PetEvent(PetEvent.ROOM_PET_SHOW,0));
         }
      }
   }
}

