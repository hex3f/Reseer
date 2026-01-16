package com.robot.app.bag
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.SuitXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.utils.ItemType;
   import flash.events.Event;
   import org.taomee.events.DynamicEvent;
   
   public class BagClothModel
   {
      
      private var _view:BagPanel;
      
      private var _itemList:Array;
      
      private var _filList:Array;
      
      private var totalPage:uint;
      
      private var currentPage:uint = 1;
      
      private var PET_NUM:uint = 12;
      
      public function BagClothModel(param1:BagPanel)
      {
         super();
         this._view = param1;
         this._view.addEventListener(Event.COMPLETE,this.onPanelComplete);
         this._view.addEventListener(Event.CLOSE,this.onPanelClose);
         this._view.addEventListener(BagPanel.NEXT_PAGE,this.nextHandler);
         this._view.addEventListener(BagPanel.PREV_PAGE,this.prevHandler);
         this._view.addEventListener(BagPanel.SHOW_CLOTH,this.onShowTab);
         this._view.addEventListener(BagPanel.SHOW_COLLECTION,this.onShowTab);
         this._view.addEventListener(BagPanel.SHOW_NONO,this.onShowTab);
         this._view.addEventListener(BagPanel.SHOW_SOULBEAD,this.onShowTab);
         this._view.addEventListener(BagTypeEvent.SELECT,this.onTypeSelect);
      }
      
      private function onPanelComplete(param1:Event) : void
      {
         this.currentPage = 1;
         this.init();
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
         ItemManager.getCloth();
      }
      
      private function onPanelClose(param1:Event) : void
      {
         this.currentPage = 1;
         this.clear();
      }
      
      private function init() : void
      {
         MainManager.actorModel.addEventListener(BagChangeClothAction.TAKE_OFF_CLOTH,this.actEventHandler);
         MainManager.actorModel.addEventListener(BagChangeClothAction.REPLACE_CLOTH,this.actEventHandler);
         MainManager.actorModel.addEventListener(BagChangeClothAction.USE_CLOTH,this.actEventHandler);
         MainManager.actorModel.addEventListener(BagChangeClothAction.CLOTH_CHANGE,this.onClothChange);
      }
      
      private function onShowTab(param1:Event) : void
      {
         this._itemList = [];
         this._filList = [];
         switch(param1.type)
         {
            case BagPanel.SHOW_CLOTH:
               ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
               ItemManager.removeEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
               ItemManager.addEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
               ItemManager.getCloth();
               break;
            case BagPanel.SHOW_COLLECTION:
               ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
               ItemManager.removeEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
               ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
               ItemManager.getCollection();
               break;
            case BagPanel.SHOW_NONO:
               ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
               ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
               ItemManager.addEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
               ItemManager.getSuper();
               break;
            case BagPanel.SHOW_SOULBEAD:
               ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
               ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
               ItemManager.removeEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
               ItemManager.addEventListener(ItemEvent.SOULBEAD_ITEM_LIST,this.onSoulBeadList);
               ItemManager.getSoulBead();
         }
      }
      
      private function getArray(param1:Array, param2:uint = 1, param3:uint = 12) : Array
      {
         var _loc4_:uint = (param2 - 1) * param3;
         var _loc5_:uint = param2 * param3;
         return param1.slice(_loc4_,_loc5_);
      }
      
      public function clear() : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
         ItemManager.removeEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
         MainManager.actorModel.removeEventListener(BagChangeClothAction.TAKE_OFF_CLOTH,this.actEventHandler);
         MainManager.actorModel.removeEventListener(BagChangeClothAction.REPLACE_CLOTH,this.actEventHandler);
         MainManager.actorModel.removeEventListener(BagChangeClothAction.USE_CLOTH,this.actEventHandler);
         MainManager.actorModel.removeEventListener(BagChangeClothAction.CLOTH_CHANGE,this.onClothChange);
      }
      
      private function onClothList(param1:Event) : void
      {
         var e:Event = param1;
         var clothes:Array = MainManager.actorInfo.clothIDs;
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onClothList);
         this._itemList = ItemManager.getClothInfos();
         this._itemList = this._itemList.filter(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
         {
            if(!ItemXMLInfo.getIsSuper(param1.itemID))
            {
               return true;
            }
            return false;
         });
         this._filList = this._itemList.concat();
         this.showItem();
      }
      
      private function onCollectonList(param1:Event) : void
      {
         var e:Event = param1;
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onCollectonList);
         this._itemList = ItemManager.getCollectionInfos();
         this._itemList = this._itemList.filter(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
         {
            if(!ItemXMLInfo.getIsSuper(param1.itemID))
            {
               return true;
            }
            return false;
         });
         this._filList = this._itemList.concat();
         this.totalPage = Math.ceil(this._filList.length / this.PET_NUM);
         if(this.totalPage == 0)
         {
            this.totalPage = 1;
         }
         this._view.setPageNum(1,this.totalPage);
         this._view.showItem(this.getArray(this._filList));
      }
      
      private function onNoNoList(param1:Event) : void
      {
         var clothes:Array = null;
         var e:Event = param1;
         clothes = null;
         clothes = MainManager.actorInfo.clothIDs;
         ItemManager.removeEventListener(ItemEvent.SUPER_ITEM_LIST,this.onNoNoList);
         this._itemList = ItemManager.getSuperInfos();
         this._itemList = this._itemList.filter(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
         {
            if(Boolean(ItemXMLInfo.getIsSuper(param1.itemID)) && clothes.indexOf(param1.itemID) == -1)
            {
               return true;
            }
            return false;
         });
         this._filList = this._itemList.concat();
         this.showItem();
      }
      
      private function onSoulBeadList(param1:Event) : void
      {
         var _loc2_:SingleItemInfo = null;
         ItemManager.removeEventListener(ItemEvent.SOULBEAD_ITEM_LIST,this.onSoulBeadList);
         this._itemList = ItemManager.getSoulBeadInfos();
         var _loc3_:Number = 0;
         while(_loc3_ < this._itemList.length)
         {
            _loc2_ = new SingleItemInfo();
            _loc2_.itemNum = 1;
            _loc2_.itemID = this._itemList[_loc3_].itemID;
            _loc2_.leftTime = 31536000;
            this._filList.push(_loc2_);
            _loc3_++;
         }
         this.showItem();
      }
      
      private function showItem() : void
      {
         this.currentPage = 1;
         switch(BagPanel.currTab)
         {
            case BagTabType.CLOTH:
            case BagTabType.NONO:
               if(BagShowType.currType != BagShowType.SUIT && BagShowType.currType != BagShowType.ALL)
               {
                  this._filList = this._itemList.filter(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
                  {
                     var _loc4_:* = undefined;
                     if(param1.type == ItemType.CLOTH)
                     {
                        if(ClothInfo.getItemInfo(param1.itemID).type == BagShowType.typeNameListEn[BagShowType.currType])
                        {
                           param2 = -1;
                           if(_view.bChangeClothes)
                           {
                              param2 = int(MainManager.actorInfo.clothIDs.indexOf(param1.itemID));
                              _view.bChangeClothes = false;
                           }
                           _loc4_ = _view.clothPrev.getClothArray().indexOf(param1.itemID);
                           if(param2 == -1 && _loc4_ == -1)
                           {
                              return true;
                           }
                        }
                     }
                     return false;
                  });
                  break;
               }
               this._filList = this._itemList.filter(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
               {
                  var _loc4_:* = undefined;
                  if(param1.type == ItemType.CLOTH)
                  {
                     param2 = -1;
                     if(_view.bChangeClothes)
                     {
                        param2 = int(MainManager.actorInfo.clothIDs.indexOf(param1.itemID));
                        _view.bChangeClothes = false;
                     }
                     _loc4_ = _view.clothPrev.getClothIDs().indexOf(param1.itemID);
                     if(param2 == -1 && _loc4_ == -1)
                     {
                        return true;
                     }
                     return false;
                  }
                  return true;
               });
               break;
            case BagTabType.SOULBEAD:
               break;
            default:
               this._filList = this._itemList.concat();
         }
         this.totalPage = Math.ceil(this._filList.length / this.PET_NUM);
         if(this.totalPage == 0)
         {
            this.totalPage = 1;
         }
         this._view.setPageNum(1,this.totalPage);
         this._view.showItem(this.getArray(this._filList));
      }
      
      private function showSuit(param1:Array) : void
      {
         var arr:Array = param1;
         this.currentPage = 1;
         this.totalPage = Math.ceil(arr.length / this.PET_NUM);
         if(this.totalPage == 0)
         {
            this.totalPage = 1;
         }
         this._view.setPageNum(1,this.totalPage);
         arr = arr.slice(0,this.PET_NUM);
         arr = arr.map(function(param1:uint, param2:int, param3:Array):SingleItemInfo
         {
            var _loc4_:* = undefined;
            for each(_loc4_ in _itemList)
            {
               if(_loc4_.itemID == param1)
               {
                  return _loc4_;
               }
            }
            _loc4_ = new SingleItemInfo();
            _loc4_.itemID = param1;
            return _loc4_;
         });
         this._view.showItem(arr);
      }
      
      private function nextHandler(param1:Event) : void
      {
         if(this.currentPage < this.totalPage)
         {
            ++this.currentPage;
            this._view.showItem(this.getArray(this._filList,this.currentPage));
            this._view.setPageNum(this.currentPage,this.totalPage);
         }
      }
      
      private function prevHandler(param1:Event) : void
      {
         if(this.currentPage > 1)
         {
            --this.currentPage;
            this._view.showItem(this.getArray(this._filList,this.currentPage));
            this._view.setPageNum(this.currentPage,this.totalPage);
         }
      }
      
      private function actEventHandler(param1:DynamicEvent) : void
      {
         var id:uint = 0;
         var event:DynamicEvent = param1;
         id = 0;
         var info:SingleItemInfo = null;
         var _index:int = 0;
         if(!this._filList)
         {
            return;
         }
         if(BagShowType.currType == BagShowType.ALL)
         {
            id = uint(event.paramObject);
            this._itemList.some(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
            {
               if(param1.itemID == id)
               {
                  info = param1;
                  return true;
               }
               return false;
            });
            _index = -1;
            this._filList.some(function(param1:SingleItemInfo, param2:int, param3:Array):Boolean
            {
               if(param1.itemID == _view.clickItemID)
               {
                  _index = param2;
                  return true;
               }
               return false;
            });
            switch(event.type)
            {
               case BagChangeClothAction.USE_CLOTH:
                  if(_index != -1)
                  {
                     this._filList.splice(_index,1);
                  }
                  break;
               case BagChangeClothAction.REPLACE_CLOTH:
                  if(_index != -1)
                  {
                     this._filList.splice(_index,1);
                     if(Boolean(info))
                     {
                        this._filList.unshift(info);
                     }
                  }
                  break;
               case BagChangeClothAction.TAKE_OFF_CLOTH:
                  if(id != 0)
                  {
                     if(Boolean(info))
                     {
                        this._filList.unshift(info);
                     }
                  }
            }
            this.totalPage = Math.ceil(this._filList.length / this.PET_NUM);
            if(this.totalPage == 0)
            {
               this.totalPage = 1;
            }
            if(this.currentPage > this.totalPage)
            {
               this.currentPage = this.totalPage;
            }
            this._view.setPageNum(this.currentPage,this.totalPage);
            if(BagPanel.currTab == BagTabType.COLLECTION)
            {
               this._view.goToCloth();
            }
            this._view.showItem(this.getArray(this._filList,this.currentPage));
         }
      }
      
      private function onClothChange(param1:Event) : void
      {
         if(BagShowType.currType == BagShowType.SUIT)
         {
            this.showSuit(SuitXMLInfo.getClothsForItem(this._view.clickItemID));
         }
      }
      
      private function onTypeSelect(param1:BagTypeEvent) : void
      {
         if(param1.showType == BagShowType.SUIT)
         {
            this.showSuit(SuitXMLInfo.getCloths(param1.suitID));
         }
         else
         {
            this.showItem();
         }
      }
   }
}

