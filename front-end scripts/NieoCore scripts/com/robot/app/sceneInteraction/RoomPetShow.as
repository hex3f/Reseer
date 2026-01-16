package com.robot.app.sceneInteraction
{
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.mode.RoomPetModel;
   import com.robot.core.pet.PetInfoController;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.ds.HashMap;
   
   public class RoomPetShow
   {
      
      private var _petMap:HashMap = new HashMap();
      
      private var _allowLen:int = 0;
      
      private var _allowArr:Array;
      
      private var _appModel:AppModel;
      
      public function RoomPetShow(param1:uint)
      {
         super();
         this._allowArr = MapManager.currentMap.allowData;
         this._allowLen = this._allowArr.length;
         RoomPetManager.getInstance().addEventListener(PetEvent.ROOM_PET_LIST,this.onList);
         RoomPetManager.getInstance().addEventListener(PetEvent.ROOM_PET_SHOW,this.onShow);
         RoomPetManager.getInstance().getShowList(param1);
         PetManager.addEventListener(PetEvent.STORAGE_REMOVED,this.onRemoveStorage);
      }
      
      public function destroy() : void
      {
         PetManager.removeEventListener(PetEvent.STORAGE_REMOVED,this.onRemoveStorage);
         RoomPetManager.getInstance().removeEventListener(PetEvent.ROOM_PET_LIST,this.onList);
         RoomPetManager.getInstance().removeEventListener(PetEvent.ROOM_PET_SHOW,this.onShow);
         this._petMap.eachKey(function(param1:uint):void
         {
            var _loc2_:RoomPetModel = _petMap.remove(param1);
            _loc2_.destroy();
            _loc2_ = null;
         });
         this._petMap = null;
         RoomPetManager.destroy();
         if(Boolean(this._appModel))
         {
            this._appModel.destroy();
         }
      }
      
      private function update() : void
      {
         var arr:Array = null;
         var info:PetListInfo = null;
         var pm:RoomPetModel = null;
         this._petMap.eachKey(function(param1:uint):void
         {
            var _loc2_:RoomPetModel = null;
            if(!RoomPetManager.getInstance().contains(param1))
            {
               _loc2_ = _petMap.remove(param1);
               _loc2_.destroy();
               _loc2_ = null;
            }
         });
         arr = RoomPetManager.getInstance().getInfos();
         for each(info in arr)
         {
            if(!this._petMap.containsKey(info.catchTime))
            {
               pm = new RoomPetModel(info);
               this._petMap.add(info.catchTime,pm);
               pm.show(this._allowArr[int(Math.random() * this._allowLen)]);
               pm.addEventListener(MouseEvent.CLICK,this.onClick);
            }
         }
      }
      
      private function onList(param1:Event) : void
      {
         RoomPetManager.getInstance().removeEventListener(PetEvent.ROOM_PET_LIST,this.onList);
         this.update();
      }
      
      private function onShow(param1:Event) : void
      {
         this.update();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:RoomPetModel = param1.currentTarget as RoomPetModel;
         PetInfoController.getInfo(true,MainManager.actorInfo.mapID,_loc2_.info.catchTime);
      }
      
      private function onRemoveStorage(param1:PetEvent) : void
      {
         RoomPetManager.getInstance().removePet(param1.catchTime());
      }
   }
}

