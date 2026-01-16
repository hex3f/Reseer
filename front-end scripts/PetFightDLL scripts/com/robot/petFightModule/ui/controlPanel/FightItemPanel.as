package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.app.superParty.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.*;
   import com.robot.core.uic.*;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.ui.controlPanel.petItem.*;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.IPetItemCategory;
   import flash.events.*;
   import org.taomee.utils.*;
   
   public class FightItemPanel extends BaseControlPanel implements IControlPanel
   {
      
      private var _scrollMc:UIScrollBar;
      
      private const MAX:uint = 10;
      
      private var _itemA:Array = [300001,300002,300003,300004,300005,300006,300007,300008];
      
      private var categoryArray:Array;
      
      private var idArray:Array;
      
      public function FightItemPanel()
      {
         super();
         _panel = new ui_ItemPanel();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         ItemManager.getCollection();
      }
      
      private function showScroll() : void
      {
         if(!this._scrollMc)
         {
            this._scrollMc = new UIScrollBar(_panel["scMc"]["bar"],_panel["scMc"]["barBack"],this.MAX);
         }
         this._scrollMc.wheelObject = _panel;
         this._scrollMc.totalLength = this.idArray.length;
         this._scrollMc.addEventListener(MouseEvent.MOUSE_MOVE,this.onScrollMove);
      }
      
      private function onScrollMove(param1:MouseEvent) : void
      {
         this.removeOldItem();
         var _loc2_:uint = uint(this._scrollMc.index);
         var _loc3_:Array = this.idArray.slice(this._scrollMc.index * this.MAX,(this._scrollMc.index + 1) * this.MAX);
         this.showPetItem(_loc3_);
      }
      
      public function clear() : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
      }
      
      private function removeOldItem() : void
      {
         var _loc1_:IPetItemCategory = null;
         if(Boolean(this.categoryArray))
         {
            for each(_loc1_ in this.categoryArray)
            {
               DisplayUtil.removeForParent(_loc1_.sprite);
               _loc1_ = null;
            }
         }
      }
      
      private function showPetItem(param1:Array) : void
      {
         var _loc2_:IPetItemCategory = null;
         this.categoryArray = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(Boolean(ItemXMLInfo.getIsSuper(param1[_loc3_])) && !MainManager.actorInfo.vip)
            {
               param1.splice(_loc3_,1);
               _loc3_--;
            }
            else
            {
               _loc2_ = PetItemCategoryFactory.getitemgory(param1[_loc3_]);
               if(!_loc2_)
               {
                  _loc3_++;
                  continue;
               }
               _loc2_.sprite.x = 15 + 56 * (_loc3_ % 5);
               _loc2_.sprite.y = 22 + 58 * Math.floor(_loc3_ / 5);
               panel.addChild(_loc2_.sprite);
               this.categoryArray.push(_loc2_);
            }
            _loc3_++;
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:IPetItemCategory = null;
         super.destroy();
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         for each(_loc1_ in this.categoryArray)
         {
            _loc1_.destroy();
         }
         this.categoryArray = [];
      }
      
      private function onList(param1:Event) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Array = null;
         this.idArray = [];
         var _loc4_:uint = FighterModeFactory.enemyMode.petID;
         if(PetFightModel.status != PetFightModel.FIGHT_WITH_BOSS)
         {
            if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER || MainManager.actorInfo.mapID == 102)
            {
               this.removeOldItem();
               if(Boolean(this._scrollMc))
               {
                  this._scrollMc.totalLength = 0;
               }
               return;
            }
         }
         for each(_loc2_ in ItemManager.getCollectionIDs())
         {
            if(_loc2_.toString().substr(0,1) == "3" && _loc2_ < 300024)
            {
               if(!(Boolean(ItemXMLInfo.getIsSuper(_loc2_)) && !MainManager.actorInfo.vip))
               {
                  if(SPChannelController.mapID == 52 || SPChannelController.mapID == 316 || SPChannelController.mapID == 329)
                  {
                     if(this._itemA.indexOf(_loc2_) == -1 && _loc2_ >= 300010)
                     {
                        this.idArray.push(_loc2_);
                     }
                  }
                  else if(_loc2_ != 300009)
                  {
                     if(_loc2_ >= 300010)
                     {
                        this.idArray.push(_loc2_);
                     }
                  }
               }
            }
         }
         this.removeOldItem();
         _loc3_ = this.idArray.slice(0,this.MAX + 1);
         this.showPetItem(_loc3_);
         if(this.idArray.length > this.MAX)
         {
            this.showScroll();
         }
         else if(Boolean(this._scrollMc))
         {
            this._scrollMc.totalLength = 0;
         }
      }
   }
}

