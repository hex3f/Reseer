package com.robot.app.sceneInteraction
{
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.HeadquarterManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.HeadquarterModel;
   import com.robot.core.utils.DragTargetType;
   import com.robot.core.utils.SolidType;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.DepthManager;
   import org.taomee.utils.ArrayUtil;
   
   public class HeadquarterShow
   {
      
      private var _currFitment:HeadquarterModel;
      
      private var _useList:Array = [];
      
      public function HeadquarterShow()
      {
         super();
         this.onUseFitment();
      }
      
      public function destroy() : void
      {
         var _loc1_:HeadquarterModel = null;
         HeadquarterManager.removeEventListener(FitmentEvent.ADD_TO_MAP,this.onAddMap);
         HeadquarterManager.removeEventListener(FitmentEvent.REMOVE_TO_MAP,this.onRemoveMap);
         HeadquarterManager.removeEventListener(FitmentEvent.REMOVE_ALL_TO_MAP,this.onRemoveAllMap);
         HeadquarterManager.destroy();
         var _loc2_:int = int(this._useList.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._useList[_loc3_] as HeadquarterModel;
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
         HeadquarterManager.addEventListener(FitmentEvent.ADD_TO_MAP,this.onAddMap);
         HeadquarterManager.addEventListener(FitmentEvent.REMOVE_TO_MAP,this.onRemoveMap);
         HeadquarterManager.addEventListener(FitmentEvent.REMOVE_ALL_TO_MAP,this.onRemoveAllMap);
         HeadquarterManager.getStorageInfo(MainManager.actorInfo.mapID);
      }
      
      public function openDrag() : void
      {
         this._useList.forEach(function(param1:HeadquarterModel, param2:int, param3:Array):void
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.mouseChildren = false;
            param1.buttonMode = true;
            param1.dragEnabled = true;
         });
      }
      
      public function closeDrag() : void
      {
         this._useList.forEach(function(param1:HeadquarterModel, param2:int, param3:Array):void
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
         var _loc1_:FitmentInfo = null;
         var _loc2_:HeadquarterModel = null;
         var _loc3_:Array = HeadquarterManager.getUsedList();
         for each(_loc1_ in _loc3_)
         {
            if(_loc1_.type != SolidType.FRAME)
            {
               if(_loc1_.isFixed)
               {
                  _loc1_.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
               }
               _loc2_ = new HeadquarterModel();
               _loc2_.show(_loc1_,MapManager.currentMap.depthLevel);
               this._useList.push(_loc2_);
            }
         }
      }
      
      private function onAddMap(param1:FitmentEvent) : void
      {
         var _loc2_:HeadquarterModel = new HeadquarterModel();
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
         _loc2_.mouseChildren = false;
         _loc2_.buttonMode = true;
         _loc2_.dragEnabled = true;
         _loc2_.show(param1.info,MapManager.currentMap.depthLevel);
         this._useList.push(_loc2_);
         DepthManager.swapDepth(_loc2_,_loc2_.y);
      }
      
      private function onRemoveMap(param1:FitmentEvent) : void
      {
         var _loc2_:HeadquarterModel = null;
         var _loc3_:int = int(MapManager.currentMap.depthLevel.numChildren);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = MapManager.currentMap.depthLevel.getChildAt(_loc4_) as HeadquarterModel;
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
      
      private function onRemoveAllMap(param1:FitmentEvent) : void
      {
         var e:FitmentEvent = param1;
         if(Boolean(this._currFitment))
         {
            this._currFitment.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
            this._currFitment = null;
         }
         this._useList.forEach(function(param1:HeadquarterModel, param2:int, param3:Array):void
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.destroy();
            param1 = null;
         });
         this._useList = [];
      }
      
      private function onFMDown(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:HeadquarterModel = param1.currentTarget as HeadquarterModel;
         var _loc4_:Sprite = _loc3_.content as Sprite;
         if(Boolean(_loc4_))
         {
            _loc2_ = new Point(param1.stageX - _loc3_.x,param1.stageY - _loc3_.y);
            HeadquarterManager.doDrag(_loc4_,_loc3_.info,_loc3_,DragTargetType.MAP,_loc2_);
         }
         this._currFitment = _loc3_;
         this._currFitment.setSelect(true);
         this._currFitment.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         var _loc2_:HeadquarterModel = param1.currentTarget as HeadquarterModel;
         _loc2_.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         _loc2_.setSelect(false);
      }
   }
}

