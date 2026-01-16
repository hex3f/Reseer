package com.robot.app.sceneInteraction
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.FitmentModel;
   import com.robot.core.utils.DragTargetType;
   import com.robot.core.utils.SolidType;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import org.taomee.manager.DepthManager;
   import org.taomee.utils.ArrayUtil;
   
   public class RoomFitment
   {
      
      private var _currFitment:FitmentModel;
      
      private var _useList:Array = [];
      
      public function RoomFitment()
      {
         super();
         this.onUseFitment();
      }
      
      public function destroy() : void
      {
         var _loc1_:FitmentModel = null;
         FitmentManager.removeEventListener(FitmentEvent.ADD_TO_MAP,this.onAddMap);
         FitmentManager.removeEventListener(FitmentEvent.REMOVE_TO_MAP,this.onRemoveMap);
         FitmentManager.removeEventListener(FitmentEvent.DRAG_IN_MAP,this.onDragInMap);
         FitmentManager.destroy();
         var _loc2_:int = int(this._useList.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._useList[_loc3_] as FitmentModel;
            if(Boolean(_loc1_))
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
               _loc1_.destroy();
               _loc1_ = null;
            }
            _loc3_++;
         }
         this._useList = null;
         if(Boolean(this._currFitment))
         {
            this._currFitment.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
            this._currFitment = null;
         }
      }
      
      public function getStorageInfo() : void
      {
         FitmentManager.addEventListener(FitmentEvent.ADD_TO_MAP,this.onAddMap);
         FitmentManager.addEventListener(FitmentEvent.REMOVE_TO_MAP,this.onRemoveMap);
         FitmentManager.addEventListener(FitmentEvent.DRAG_IN_MAP,this.onDragInMap);
         FitmentManager.getStorageInfo();
      }
      
      private function onDragInMap(param1:FitmentEvent) : void
      {
         var _loc2_:FitmentModel = null;
         for each(_loc2_ in this._useList)
         {
            if(ItemXMLInfo.getIsFloor(_loc2_.info.id))
            {
               _loc2_.parent.addChildAt(_loc2_,0);
            }
         }
      }
      
      public function openDrag() : void
      {
         this._useList.forEach(function(param1:FitmentModel, param2:int, param3:Array):void
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.mouseChildren = false;
            param1.buttonMode = true;
            param1.dragEnabled = true;
         });
      }
      
      public function closeDrag() : void
      {
         this._useList.forEach(function(param1:FitmentModel, param2:int, param3:Array):void
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.mouseChildren = true;
            if(param1.funID == 0)
            {
               param1.buttonMode = false;
            }
            param1.dragEnabled = false;
         });
      }
      
      private function onUseFitment() : void
      {
         var info:FitmentInfo = null;
         var fm:FitmentModel = null;
         var arr:Array = FitmentManager.getUsedList();
         for each(info in arr)
         {
            if(info.type != SolidType.FRAME)
            {
               fm = new FitmentModel();
               fm.show(info,MapManager.currentMap.depthLevel);
               this._useList.push(fm);
            }
         }
         setTimeout(function():void
         {
            var _loc1_:FitmentModel = null;
            for each(_loc1_ in _useList)
            {
               if(ItemXMLInfo.getIsFloor(_loc1_.info.id))
               {
                  _loc1_.parent.addChildAt(_loc1_,0);
               }
            }
         },500);
      }
      
      private function onAddMap(param1:FitmentEvent) : void
      {
         var _loc2_:FitmentModel = null;
         var _loc3_:FitmentModel = new FitmentModel();
         _loc3_.addEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
         _loc3_.mouseChildren = false;
         _loc3_.buttonMode = true;
         _loc3_.dragEnabled = true;
         _loc3_.show(param1.info,MapManager.currentMap.depthLevel);
         this._useList.push(_loc3_);
         DepthManager.swapDepth(_loc3_,_loc3_.y);
         for each(_loc2_ in this._useList)
         {
            if(ItemXMLInfo.getIsFloor(_loc2_.info.id))
            {
               _loc2_.parent.addChildAt(_loc2_,0);
            }
         }
      }
      
      private function onRemoveMap(param1:FitmentEvent) : void
      {
         var _loc2_:FitmentModel = null;
         var _loc3_:int = int(MapManager.currentMap.depthLevel.numChildren);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = MapManager.currentMap.depthLevel.getChildAt(_loc4_) as FitmentModel;
            if(Boolean(_loc2_))
            {
               if(_loc2_.info == param1.info)
               {
                  if(this._currFitment == _loc2_)
                  {
                     this._currFitment.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
                     this._currFitment = null;
                  }
                  ArrayUtil.removeValueFromArray(this._useList,_loc2_);
                  _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
                  _loc2_.destroy();
                  _loc2_ = null;
                  return;
               }
            }
            _loc4_++;
         }
      }
      
      private function onFMDown(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:FitmentModel = param1.currentTarget as FitmentModel;
         var _loc4_:Sprite = _loc3_.content as Sprite;
         if(Boolean(_loc4_))
         {
            _loc2_ = new Point(param1.stageX - _loc3_.x,param1.stageY - _loc3_.y);
            FitmentManager.doDrag(_loc4_,_loc3_.info,_loc3_,DragTargetType.MAP,_loc2_);
         }
         this._currFitment = _loc3_;
         this._currFitment.setSelect(true);
         this._currFitment.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         var _loc2_:FitmentModel = param1.currentTarget as FitmentModel;
         _loc2_.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         _loc2_.setSelect(false);
      }
   }
}

