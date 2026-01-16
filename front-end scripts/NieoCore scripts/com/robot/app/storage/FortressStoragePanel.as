package com.robot.app.storage
{
   import com.robot.core.event.ArmEvent;
   import com.robot.core.manager.ArmManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.uic.UIPageBar;
   import com.robot.core.utils.DragTargetType;
   import com.robot.core.utils.SolidType;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import gs.TweenLite;
   import gs.easing.Expo;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.utils.DisplayUtil;
   
   public class FortressStoragePanel extends Sprite
   {
      
      private static const MAX:int = 10;
      
      private static const TABID:Array = [7,8,9,1,4];
      
      private var _mainUI:Sprite;
      
      private var _listCon:Sprite;
      
      private var _closeBtn:SimpleButton;
      
      private var _dragBtn:SimpleButton;
      
      private var _dataList:Array;
      
      private var _dataLen:int;
      
      private var _isTween:Boolean = false;
      
      private var _pageBar:UIPageBar;
      
      private var _type:uint = 7;
      
      private var _currTab:MovieClip;
      
      public function FortressStoragePanel()
      {
         var _loc1_:FortressStorageListItem = null;
         var _loc2_:* = 0;
         var _loc3_:MovieClip = null;
         super();
         this._mainUI = UIManager.getSprite("UI_ForStorage_ToolBar");
         this._dragBtn = this._mainUI["dragBtn"];
         this._closeBtn = this._mainUI["closeBtn"];
         this._mainUI.mouseEnabled = false;
         addChild(this._mainUI);
         this._listCon = new Sprite();
         this._listCon.x = 62;
         this._listCon.y = 11;
         addChild(this._listCon);
         var _loc4_:int = 0;
         while(_loc4_ < MAX)
         {
            _loc1_ = new FortressStorageListItem();
            _loc1_.x = (_loc1_.width + 8) * _loc4_;
            this._listCon.addChild(_loc1_);
            _loc4_++;
         }
         this._pageBar = new UIPageBar(this._mainUI["preBtn"],this._mainUI["nextBtn"],new TextField(),MAX);
         var _loc5_:int = 0;
         while(_loc5_ < 5)
         {
            _loc2_ = uint(TABID[_loc5_]);
            _loc3_ = this._mainUI.getChildByName("tab_" + _loc2_.toString()) as MovieClip;
            _loc3_.buttonMode = true;
            _loc3_.mouseChildren = false;
            _loc3_.gotoAndStop(1);
            _loc3_.addEventListener(MouseEvent.CLICK,this.onTabClick);
            _loc3_.typeID = _loc2_;
            if(_loc5_ == 0)
            {
               this._currTab = _loc3_;
            }
            _loc5_++;
         }
         this._currTab.gotoAndStop(2);
         this._currTab.mouseEnabled = false;
         DepthManager.bringToTop(this._currTab);
      }
      
      public function show() : void
      {
         if(this._isTween)
         {
            return;
         }
         y = MainManager.getStageHeight();
         x = (MainManager.getStageWidth() - width) / 2;
         alpha = 1;
         LevelManager.appLevel.addChild(this);
         TweenLite.to(this,0.6,{
            "y":MainManager.getStageHeight() - height + 28,
            "ease":Expo.easeOut
         });
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
         this._pageBar.addEventListener(MouseEvent.CLICK,this.onProPage);
         ArmManager.addEventListener(ArmEvent.ADD_TO_STORAGE,this.onUnUsedFitment);
         ArmManager.addEventListener(ArmEvent.REMOVE_TO_STORAGE,this.onUnUsedFitment);
         ArmManager.addEventListener(ArmEvent.ALL_LIST,this.onUnUsedFitment);
         ArmManager.addEventListener(ArmEvent.UP_ALL_LIST,this.onUnUsedFitment);
         this.reItem();
      }
      
      public function hide() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onClose);
         this._dragBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.removeEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
         this._pageBar.removeEventListener(MouseEvent.CLICK,this.onProPage);
         ArmManager.removeEventListener(ArmEvent.ADD_TO_STORAGE,this.onUnUsedFitment);
         ArmManager.removeEventListener(ArmEvent.REMOVE_TO_STORAGE,this.onUnUsedFitment);
         ArmManager.removeEventListener(ArmEvent.ALL_LIST,this.onUnUsedFitment);
         ArmManager.removeEventListener(ArmEvent.UP_ALL_LIST,this.onUnUsedFitment);
         TweenLite.to(this,0.6,{
            "alpha":0,
            "onComplete":this.onFinishTween
         });
         this._isTween = true;
      }
      
      public function destroy() : void
      {
         this.hide();
         this._pageBar.destroy();
         this._pageBar = null;
         this._dataList = null;
         this._listCon = null;
         this._dragBtn = null;
         this._closeBtn = null;
         this._mainUI = null;
      }
      
      public function reItem() : void
      {
         var _loc1_:FortressStorageListItem = null;
         this._dataList = ArmManager.getUnUsedListForType(this._type);
         this._dataLen = this._dataList.length;
         this.clearItem();
         if(this._dataLen == 0)
         {
            return;
         }
         this._pageBar.totalLength = this._dataLen;
         var _loc2_:int = Math.min(MAX,this._dataLen);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._listCon.getChildAt(_loc3_) as FortressStorageListItem;
            _loc1_.info = this._dataList[_loc3_ + this._pageBar.index];
            _loc1_.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemDown);
            _loc3_++;
         }
      }
      
      private function clearItem() : void
      {
         var _loc1_:FortressStorageListItem = null;
         var _loc2_:int = this._listCon.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._listCon.getChildAt(_loc3_) as FortressStorageListItem;
            _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemDown);
            _loc1_.destroy();
            _loc3_++;
         }
      }
      
      private function onProPage(param1:DynamicEvent) : void
      {
         var _loc2_:FortressStorageListItem = null;
         this.clearItem();
         var _loc3_:uint = param1.paramObject as uint;
         var _loc4_:int = Math.min(MAX,this._pageBar.totalLength - this._pageBar.index * MAX);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = this._listCon.getChildAt(_loc5_) as FortressStorageListItem;
            _loc2_.destroy();
            _loc2_.info = this._dataList[_loc5_ + this._pageBar.index * MAX];
            _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemDown);
            _loc5_++;
         }
      }
      
      private function onFinishTween() : void
      {
         this._isTween = false;
         DisplayUtil.removeForParent(this);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.hide();
      }
      
      private function onDragDown(param1:MouseEvent) : void
      {
         startDrag();
      }
      
      private function onDragUp(param1:MouseEvent) : void
      {
         stopDrag();
      }
      
      private function onItemDown(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:BitmapData = null;
         if(!ArmManager.dragInMapEnabled)
         {
            Alarm.show("当前战队等级最多只能摆放" + ArmManager.getMax() + "个可升级设施");
            return;
         }
         var _loc4_:FortressStorageListItem = param1.currentTarget as FortressStorageListItem;
         if(_loc4_.info.type == SolidType.FRAME)
         {
            return;
         }
         var _loc5_:Sprite = _loc4_.obj as Sprite;
         if(Boolean(_loc5_))
         {
            if(_loc4_.info.unUsedCount > 1)
            {
               _loc2_ = _loc5_.localToGlobal(new Point());
               _loc3_ = new BitmapData(_loc5_.width,_loc5_.height,true,0);
               _loc3_.draw(_loc5_);
               _loc5_ = new Sprite();
               _loc5_.addChild(new Bitmap(_loc3_));
               _loc5_.x = _loc2_.x;
               _loc5_.y = _loc2_.y;
            }
            ArmManager.doDrag(_loc5_,_loc4_.info,_loc4_,DragTargetType.STORAGE);
         }
      }
      
      private function onUnUsedFitment(param1:ArmEvent) : void
      {
         this.reItem();
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         this._type = _loc2_.typeID;
         this._currTab.gotoAndStop(1);
         DepthManager.bringToBottom(this._currTab);
         this._currTab.mouseEnabled = true;
         this._currTab = _loc2_;
         this._currTab.gotoAndStop(2);
         DepthManager.bringToTop(this._currTab);
         this._currTab.mouseEnabled = false;
         this._pageBar.index = 0;
         this.reItem();
      }
   }
}

