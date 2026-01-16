package com.robot.app.storage
{
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.ui.alert.Alert;
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
   
   public class StoragePanel extends Sprite
   {
      
      private static const MAX:int = 10;
      
      private static const TYPE_LIST:Array = [4,5,1,11];
      
      private var _mainUI:Sprite;
      
      private var _listCon:Sprite;
      
      private var _closeBtn:SimpleButton;
      
      private var _dragBtn:SimpleButton;
      
      private var _dataList:Array;
      
      private var _dataLen:int;
      
      private var _isTween:Boolean = false;
      
      private var _pageBar:UIPageBar;
      
      private var _type:uint = 4;
      
      private var _currTab:MovieClip;
      
      public function StoragePanel()
      {
         var _loc4_:int = 0;
         var _loc1_:StorageListItem = null;
         var _loc2_:MovieClip = null;
         super();
         this._mainUI = UIManager.getSprite("Storage_ToolBar");
         this._dragBtn = this._mainUI["dragBtn"];
         this._closeBtn = this._mainUI["closeBtn"];
         this._mainUI.mouseEnabled = false;
         addChild(this._mainUI);
         this._listCon = new Sprite();
         this._listCon.x = 62;
         this._listCon.y = 11;
         addChild(this._listCon);
         var _loc3_:int = 0;
         while(_loc3_ < MAX)
         {
            _loc1_ = new StorageListItem();
            _loc1_.x = (_loc1_.width + 8) * _loc3_;
            this._listCon.addChild(_loc1_);
            _loc3_++;
         }
         this._pageBar = new UIPageBar(this._mainUI["preBtn"],this._mainUI["nextBtn"],new TextField(),MAX);
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            _loc2_ = this._mainUI.getChildByName("tab_" + _loc4_.toString()) as MovieClip;
            _loc2_.buttonMode = true;
            _loc2_.mouseChildren = false;
            _loc2_.gotoAndStop(1);
            _loc2_.addEventListener(MouseEvent.CLICK,this.onTabClick);
            _loc2_.typeID = TYPE_LIST[_loc4_];
            if(_loc4_ == 0)
            {
               this._currTab = _loc2_;
            }
            _loc4_++;
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
         FitmentManager.addEventListener(FitmentEvent.ADD_TO_STORAGE,this.onUnUsedFitment);
         FitmentManager.addEventListener(FitmentEvent.REMOVE_TO_STORAGE,this.onUnUsedFitment);
         FitmentManager.addEventListener(FitmentEvent.STORAGE_LIST,this.onUnUsedFitment);
         this.reItem();
      }
      
      public function hide() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.CLICK,this.onClose);
         this._dragBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.removeEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
         this._pageBar.removeEventListener(MouseEvent.CLICK,this.onProPage);
         FitmentManager.removeEventListener(FitmentEvent.ADD_TO_STORAGE,this.onUnUsedFitment);
         FitmentManager.removeEventListener(FitmentEvent.REMOVE_TO_STORAGE,this.onUnUsedFitment);
         FitmentManager.removeEventListener(FitmentEvent.STORAGE_LIST,this.onUnUsedFitment);
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
         var _loc1_:StorageListItem = null;
         this._dataList = FitmentManager.getUnUsedListForType(this._type);
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
            _loc1_ = this._listCon.getChildAt(_loc3_) as StorageListItem;
            _loc1_.info = this._dataList[_loc3_ + this._pageBar.index];
            _loc1_.addEventListener(MouseEvent.MOUSE_DOWN,this.onItemDown);
            _loc3_++;
         }
      }
      
      private function clearItem() : void
      {
         var _loc1_:StorageListItem = null;
         var _loc2_:int = this._listCon.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._listCon.getChildAt(_loc3_) as StorageListItem;
            _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemDown);
            _loc1_.destroy();
            _loc3_++;
         }
      }
      
      private function onProPage(param1:DynamicEvent) : void
      {
         var _loc2_:StorageListItem = null;
         this.clearItem();
         var _loc3_:uint = param1.paramObject as uint;
         var _loc4_:int = Math.min(MAX,this._pageBar.totalLength - this._pageBar.index * MAX);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = this._listCon.getChildAt(_loc5_) as StorageListItem;
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
         var obj:Sprite = null;
         var item:StorageListItem = null;
         var e:MouseEvent = param1;
         item = null;
         var p:Point = null;
         var bmd:BitmapData = null;
         item = e.currentTarget as StorageListItem;
         if(item.info.type == SolidType.FRAME)
         {
            Alert.show("你确定换房型吗？",function():void
            {
               LevelManager.closeMouseEvent();
               FitmentManager.saveRoomType(item.info,function():void
               {
                  MapManager.refMap();
               });
            });
            return;
         }
         obj = item.obj as Sprite;
         if(Boolean(obj))
         {
            if(item.info.unUsedCount > 1)
            {
               p = obj.localToGlobal(new Point());
               bmd = new BitmapData(obj.width,obj.height,true,0);
               bmd.draw(obj);
               obj = new Sprite();
               obj.addChild(new Bitmap(bmd));
               obj.x = p.x;
               obj.y = p.y;
            }
            FitmentManager.doDrag(obj,item.info,item,DragTargetType.STORAGE);
         }
      }
      
      private function onUnUsedFitment(param1:FitmentEvent) : void
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

