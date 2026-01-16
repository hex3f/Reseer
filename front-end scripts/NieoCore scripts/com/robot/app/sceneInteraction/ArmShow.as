package com.robot.app.sceneInteraction
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.event.ArmEvent;
   import com.robot.core.info.team.ArmInfo;
   import com.robot.core.info.team.DonateInfo;
   import com.robot.core.info.team.WorkInfo;
   import com.robot.core.manager.ArmManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.ArmModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.DragTargetType;
   import com.robot.core.utils.SolidType;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.utils.ArrayUtil;
   
   public class ArmShow
   {
      
      private var _currArm:ArmModel;
      
      private var _useList:Array = [];
      
      private var _upUseList:Array = [];
      
      public function ArmShow()
      {
         super();
         this.onUseArm();
         this.onUpUseArm();
         SocketConnection.addCmdListener(CommandID.ARM_UP_SET_INFO,this.onSetUpInfo);
         SocketConnection.addCmdListener(CommandID.ARM_UP_UPDATE,this.onUpUpdate);
         SocketConnection.addCmdListener(CommandID.ARM_UP_WORK,this.onUpWork);
         SocketConnection.addCmdListener(CommandID.ARM_UP_DONATE,this.onUpDonate);
      }
      
      public function destroy() : void
      {
         SocketConnection.removeCmdListener(CommandID.ARM_UP_SET_INFO,this.onSetUpInfo);
         SocketConnection.removeCmdListener(CommandID.ARM_UP_UPDATE,this.onUpUpdate);
         SocketConnection.removeCmdListener(CommandID.ARM_UP_WORK,this.onUpWork);
         SocketConnection.removeCmdListener(CommandID.ARM_UP_DONATE,this.onUpDonate);
         ArmManager.removeEventListener(ArmEvent.ADD_TO_MAP,this.onAddMap);
         ArmManager.removeEventListener(ArmEvent.REMOVE_TO_MAP,this.onRemoveMap);
         ArmManager.removeEventListener(ArmEvent.REMOVE_ALL_TO_MAP,this.onRemoveAllMap);
         ArmManager.removeEventListener(ArmEvent.UP_USED_LIST,this.onUpUseEvent);
         ArmManager.destroy();
         this._useList = this._useList.concat(this._upUseList);
         this._useList.forEach(function(param1:ArmModel, param2:int, param3:Array):void
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.destroy();
            param1 = null;
         });
         this._useList = null;
         this._upUseList = null;
         if(Boolean(this._currArm))
         {
            this._currArm.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
            this._currArm = null;
         }
      }
      
      public function getAllInfoForServer() : void
      {
         ArmManager.addEventListener(ArmEvent.ADD_TO_MAP,this.onAddMap);
         ArmManager.addEventListener(ArmEvent.REMOVE_TO_MAP,this.onRemoveMap);
         ArmManager.addEventListener(ArmEvent.REMOVE_ALL_TO_MAP,this.onRemoveAllMap);
         ArmManager.getAllInfoForServer(MainManager.actorInfo.mapID);
         ArmManager.getAllInfoForServer_Up(MainManager.actorInfo.mapID);
      }
      
      public function openDrag() : void
      {
         var arr:Array = this._useList.concat(this._upUseList);
         arr.forEach(function(param1:ArmModel, param2:int, param3:Array):void
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.mouseChildren = false;
            param1.buttonMode = true;
            param1.dragEnabled = true;
         });
      }
      
      public function closeDrag() : void
      {
         var arr:Array = this._useList.concat(this._upUseList);
         arr.forEach(function(param1:ArmModel, param2:int, param3:Array):void
         {
            param1.removeEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
            param1.mouseChildren = true;
            if(param1.funID == 0 && param1.info.form == 0)
            {
               param1.buttonMode = false;
            }
            param1.dragEnabled = false;
         });
      }
      
      public function addArm(param1:ArmInfo) : void
      {
         var _loc2_:ArmModel = new ArmModel();
         _loc2_.mouseChildren = false;
         _loc2_.buttonMode = true;
         _loc2_.dragEnabled = true;
         if(param1.buyTime == 0)
         {
            this._useList.push(_loc2_);
         }
         else
         {
            this._upUseList.push(_loc2_);
         }
         _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
         _loc2_.show(param1,MapManager.currentMap.depthLevel);
         DepthManager.swapDepth(_loc2_,_loc2_.y);
      }
      
      public function removeArm(param1:ArmInfo) : void
      {
         var _loc2_:ArmModel = null;
         var _loc3_:DisplayObjectContainer = MapManager.currentMap.depthLevel;
         var _loc4_:int = _loc3_.numChildren;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = _loc3_.getChildAt(_loc5_) as ArmModel;
            if(Boolean(_loc2_))
            {
               if(param1.buyTime == 0)
               {
                  if(_loc2_.info == param1)
                  {
                     if(this._currArm == _loc2_)
                     {
                        this._currArm.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
                        this._currArm = null;
                     }
                     ArrayUtil.removeValueFromArray(this._useList,_loc2_);
                     _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
                     _loc2_.destroy();
                     _loc2_ = null;
                     return;
                  }
               }
               else if(_loc2_.info.buyTime == param1.buyTime)
               {
                  if(this._currArm == _loc2_)
                  {
                     this._currArm.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
                     this._currArm = null;
                  }
                  ArrayUtil.removeValueFromArray(this._upUseList,_loc2_);
                  _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
                  _loc2_.destroy();
                  _loc2_ = null;
                  return;
               }
            }
            _loc5_++;
         }
      }
      
      private function onUseArm() : void
      {
         var _loc1_:ArmInfo = null;
         var _loc2_:ArmModel = null;
         this._useList = [];
         var _loc3_:Array = ArmManager.getUsedList();
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = new ArmModel();
            _loc2_.show(_loc1_,MapManager.currentMap.depthLevel);
            this._useList.push(_loc2_);
         }
      }
      
      private function onUpUseArm() : void
      {
         ArmManager.addEventListener(ArmEvent.UP_USED_LIST,this.onUpUseEvent);
         ArmManager.getUsedInfoForServer_Up(MainManager.actorInfo.mapID);
      }
      
      private function onUpUseEvent(param1:ArmEvent) : void
      {
         var _loc2_:ArmInfo = null;
         var _loc3_:ArmModel = null;
         ArmManager.removeEventListener(ArmEvent.UP_USED_LIST,this.onUpUseEvent);
         this._upUseList = [];
         var _loc4_:Array = ArmManager.getUsedList_Up();
         for each(_loc2_ in _loc4_)
         {
            if(_loc2_.type == SolidType.HEAD)
            {
               _loc2_.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
            }
            _loc3_ = new ArmModel();
            this._upUseList.push(_loc3_);
            _loc3_.show(_loc2_,MapManager.currentMap.depthLevel);
         }
      }
      
      private function onAddMap(param1:ArmEvent) : void
      {
         this.addArm(param1.info);
      }
      
      private function onRemoveMap(param1:ArmEvent) : void
      {
         this.removeArm(param1.info);
      }
      
      private function onRemoveAllMap(param1:ArmEvent) : void
      {
         var e:ArmEvent = param1;
         var tempam:ArmModel = null;
         if(Boolean(this._currArm))
         {
            this._currArm.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
            this._currArm = null;
         }
         this._useList = this._useList.concat(this._upUseList);
         this._useList.forEach(function(param1:ArmModel, param2:int, param3:Array):void
         {
            if(param1.info.type != SolidType.HEAD)
            {
               param1.removeEventListener(MouseEvent.MOUSE_DOWN,onFMDown);
               param1.destroy();
               param1 = null;
            }
            else
            {
               tempam = param1;
            }
         });
         this._useList = [];
         this._upUseList = [tempam];
      }
      
      private function onFMDown(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:ArmModel = param1.currentTarget as ArmModel;
         var _loc4_:Sprite = _loc3_.content as Sprite;
         if(Boolean(_loc4_))
         {
            if(_loc3_.info.type != SolidType.HEAD)
            {
               _loc2_ = new Point(param1.stageX - _loc3_.x,param1.stageY - _loc3_.y);
               ArmManager.doDrag(_loc4_,_loc3_.info,_loc3_,DragTargetType.MAP,_loc2_);
            }
         }
         this._currArm = _loc3_;
         this._currArm.setSelect(true);
         this._currArm.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
      }
      
      private function onFocusOut(param1:FocusEvent) : void
      {
         var _loc2_:ArmModel = param1.currentTarget as ArmModel;
         _loc2_.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         _loc2_.setSelect(false);
      }
      
      private function onSetUpInfo(param1:SocketEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:ArmModel = null;
         var _loc4_:int = 0;
         var _loc5_:ByteArray = param1.data as ByteArray;
         var _loc6_:uint = _loc5_.readUnsignedInt();
         if(_loc6_ == MainManager.actorInfo.teamInfo.id)
         {
            if(MainManager.actorInfo.teamInfo.priv == 0)
            {
               return;
            }
         }
         var _loc7_:uint = _loc5_.readUnsignedInt();
         var _loc8_:Array = this._upUseList.slice();
         var _loc9_:int = int(_loc8_.length);
         var _loc10_:ArmInfo = new ArmInfo();
         var _loc11_:int = 0;
         while(_loc11_ < _loc7_)
         {
            _loc2_ = false;
            ArmInfo.setFor2964(_loc10_,_loc5_);
            _loc4_ = 0;
            while(_loc4_ < _loc9_)
            {
               _loc3_ = _loc8_[_loc4_];
               if(_loc10_.buyTime == _loc3_.info.buyTime)
               {
                  _loc2_ = true;
                  if(_loc10_.id != 1)
                  {
                     _loc3_.setBufForInfo(_loc10_);
                  }
                  _loc8_.splice(_loc4_,1);
                  _loc9_ = int(_loc8_.length);
                  break;
               }
               _loc4_++;
            }
            if(!_loc2_)
            {
               this.addArm(_loc10_);
            }
            _loc11_++;
         }
         if(_loc8_.length > 0)
         {
            for each(_loc3_ in _loc8_)
            {
               if(_loc3_.info.buyTime == 0)
               {
                  ArrayUtil.removeValueFromArray(this._useList,_loc3_);
               }
               else
               {
                  ArrayUtil.removeValueFromArray(this._upUseList,_loc3_);
               }
               if(this._currArm == _loc3_)
               {
                  this._currArm.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
                  this._currArm = null;
               }
               _loc3_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFMDown);
               _loc3_.destroy();
               _loc3_ = null;
            }
            _loc8_ = null;
         }
      }
      
      private function onUpUpdate(param1:SocketEvent) : void
      {
         var _loc2_:ArmModel = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:uint = _loc3_.readUnsignedInt();
         var _loc6_:uint = _loc3_.readUnsignedInt();
         for each(_loc2_ in this._upUseList)
         {
            if(_loc2_.info.buyTime == _loc4_)
            {
               _loc2_.setFormUpDate(_loc6_);
               _loc2_.info.workCount = 0;
               _loc2_.info.donateCount = 0;
               _loc2_.info.res.clear();
               _loc2_.info.resNum = 0;
               break;
            }
         }
      }
      
      private function onUpWork(param1:SocketEvent) : void
      {
         var _loc2_:ArmModel = null;
         var _loc3_:WorkInfo = param1.data as WorkInfo;
         if(_loc3_.resID == 400050)
         {
            for each(_loc2_ in this._upUseList)
            {
               if(_loc2_.info.buyTime == _loc3_.buyTime)
               {
                  _loc2_.setWork(_loc3_.workCount,_loc3_.totalRes);
                  break;
               }
            }
         }
      }
      
      private function onUpDonate(param1:SocketEvent) : void
      {
         var _loc2_:ArmModel = null;
         var _loc3_:DonateInfo = param1.data as DonateInfo;
         for each(_loc2_ in this._upUseList)
         {
            if(_loc2_.info.buyTime == _loc3_.buyTime)
            {
               _loc2_.info.donateCount = _loc3_.donateCount;
               _loc2_.info.resNum = _loc3_.totalRes;
               break;
            }
         }
      }
   }
}

