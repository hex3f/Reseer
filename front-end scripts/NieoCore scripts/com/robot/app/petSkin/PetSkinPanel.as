package com.robot.app.petSkin
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.*;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.*;
   
   public class PetSkinPanel extends Sprite
   {
      
      private static const MAX_LIST:int = 12;
      
      private var _mainUI:MovieClip;
      
      private var _okBtn:SimpleButton;
      
      private var _closeBtn:SimpleButton;
      
      private var _dragBtn:SimpleButton;
      
      private var app:ApplicationDomain;
      
      private var _listCon:Sprite;
      
      private var _selectItem:PetListItem;
      
      private var _data:Array = [];
      
      public function PetSkinPanel()
      {
         super();
      }
      
      public function setup(param1:MCLoadEvent) : void
      {
         var _loc2_:PetListItem = null;
         this.app = param1.getApplicationDomain();
         this._mainUI = new (this.app.getDefinition("Pet_SkinMc") as Class)() as MovieClip;
         addChild(this._mainUI);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(this);
         this._okBtn = this._mainUI["okBtn"];
         this._closeBtn = this._mainUI["closeBtn"];
         this._dragBtn = this._mainUI["dragBtn"];
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onCloseBtnClick);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
         this._listCon = new Sprite();
         this._listCon.x = 17;
         this._listCon.y = 14;
         this._mainUI.addChild(this._listCon);
         _loc2_ = null;
         var _loc3_:int = 0;
         while(_loc3_ < MAX_LIST)
         {
            _loc2_ = new PetListItem(this.app);
            _loc2_.x = _loc2_.width * int(_loc3_ % 4);
            _loc2_.y = _loc2_.height * int(_loc3_ / 4);
            this._listCon.addChild(_loc2_);
            _loc3_++;
         }
         var _loc4_:PetListInfo = null;
         this._data = [];
         var _loc5_:int = 0;
         while(_loc5_ < 3)
         {
            _loc4_ = new PetListInfo();
            _loc4_.id = 10;
            _loc4_.catchTime = 0;
            _loc4_.skinID = 4730 + _loc5_;
            this._data.push(_loc4_);
            _loc5_++;
         }
         this.reItem();
         this.setSelectItem();
      }
      
      private function onDragDown(param1:MouseEvent) : void
      {
         this._mainUI.startDrag();
      }
      
      private function onDragUp(param1:MouseEvent) : void
      {
         this._mainUI.stopDrag();
      }
      
      public function onCloseBtnClick(param1:MouseEvent) : void
      {
         LevelManager.openMouseEvent();
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onCloseBtnClick);
         this.destroy();
      }
      
      private function reItem() : void
      {
         var _loc1_:PetListItem = null;
         this.clearItem();
         var _loc2_:int = 0;
         while(_loc2_ < this._data.length)
         {
            _loc1_ = this._listCon.getChildAt(_loc2_) as PetListItem;
            _loc1_.info = this._data[_loc2_];
            _loc1_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc1_.mouseEnabled = true;
            _loc2_++;
         }
      }
      
      private function setSelectItem() : void
      {
         this._selectItem = this._listCon.getChildAt(0) as PetListItem;
         this._selectItem.select = true;
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         this._selectItem.select = false;
         this._selectItem = _loc2_.target as PetListItem;
         this._selectItem.select = true;
      }
      
      private function clearItem() : void
      {
         var _loc1_:PetListItem = null;
         this._selectItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < MAX_LIST)
         {
            _loc1_ = this._listCon.getChildAt(_loc2_) as PetListItem;
            _loc1_.mouseEnabled = false;
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onItemClick);
            _loc1_.clear();
            _loc1_.select = false;
            _loc2_++;
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeAllChild(this._mainUI);
            DisplayUtil.removeForParent(this._mainUI);
         }
         this._closeBtn = null;
         this._okBtn = null;
         this._mainUI = null;
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         if(this._mainUI == null)
         {
            _loc1_ = new MCLoader(ClientConfig.getAppModule("PetSkin"),this,1,"正在打开精灵皮肤...");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.setup);
            _loc1_.doLoad();
         }
         else
         {
            DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(this._mainUI);
         }
      }
   }
}

