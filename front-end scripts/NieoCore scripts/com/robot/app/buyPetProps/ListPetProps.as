package com.robot.app.buyPetProps
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ListPetProps
   {
      
      private var _mc:MovieClip;
      
      private var _itemID:uint;
      
      private var _iconMC:MovieClip;
      
      private var _point:Point;
      
      public function ListPetProps(param1:MovieClip, param2:uint, param3:MovieClip, param4:Point)
      {
         super();
         this._mc = param1;
         this._itemID = param2;
         this._iconMC = param3;
         this._point = param4;
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         ItemManager.upDateCollection(param2);
      }
      
      public function destroy() : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
      }
      
      private function onList(param1:Event) : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         var _loc2_:SingleItemInfo = ItemManager.getCollectionInfo(this._itemID);
         var _loc3_:String = ItemXMLInfo.getName(this._itemID);
         if(Boolean(_loc2_))
         {
            if(_loc2_.itemNum == 99)
            {
               Alarm.show("你已经拥有了99个" + _loc3_);
               return;
            }
         }
         BuyTipPanel.initPanel(this._mc,this._itemID,this._iconMC,this._point,this);
      }
   }
}

