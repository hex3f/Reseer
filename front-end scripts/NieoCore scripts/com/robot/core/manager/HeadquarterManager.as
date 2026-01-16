package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.event.FitmentEvent;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.info.team.HeadquarterInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.utils.DragTargetType;
   import com.robot.core.utils.SolidType;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.utils.DisplayUtil;
   
   public class HeadquarterManager
   {
      
      public static var isChange:Boolean;
      
      public static var storagePanel:Sprite;
      
      public static var teamID:uint;
      
      public static var headquartersID:uint;
      
      private static var _sprite:Sprite;
      
      private static var _info:FitmentInfo;
      
      private static var _parent:DisplayObjectContainer;
      
      private static var _type:int;
      
      private static var _offp:Point;
      
      private static var _wapmc:DisplayObject;
      
      private static var _flomc:DisplayObject;
      
      private static var _isMove:Boolean;
      
      private static var _instance:EventDispatcher;
      
      private static var usedList:Array = [];
      
      private static var storageMap:HashMap = new HashMap();
      
      private static var _isArrlowInMap:Boolean = true;
      
      public function HeadquarterManager()
      {
         super();
      }
      
      public static function doDrag(param1:Sprite, param2:FitmentInfo, param3:DisplayObjectContainer, param4:int, param5:Point = null) : void
      {
         var _loc6_:Point = null;
         _loc6_ = null;
         _sprite = param1;
         _sprite.mouseEnabled = false;
         _sprite.mouseChildren = false;
         _info = param2;
         _parent = param3;
         _type = param4;
         if(Boolean(param5))
         {
            _offp = param5;
         }
         else
         {
            _offp = new Point();
         }
         _loc6_ = DisplayUtil.localToLocal(_sprite,MainManager.getStage());
         _sprite.x = _loc6_.x;
         _sprite.y = _loc6_.y;
         MainManager.getStage().addChild(_sprite);
         MainManager.getStage().addEventListener(MouseEvent.MOUSE_UP,onUp);
         MainManager.getStage().addEventListener(MouseEvent.MOUSE_MOVE,onMove);
         var _loc7_:Rectangle = _sprite.getRect(_sprite);
         _sprite.startDrag(false,new Rectangle(-_loc7_.x,-_loc7_.y,MainManager.getStageWidth() - _loc7_.width,MainManager.getStageHeight() - _loc7_.height));
         if(Boolean(MapManager.currentMap.animatorLevel))
         {
            _wapmc = MapManager.currentMap.animatorLevel.getChildByName("wapMC");
            _flomc = MapManager.currentMap.animatorLevel.getChildByName("floMC");
         }
         _isMove = false;
      }
      
      public static function saveInfo() : void
      {
         var _loc1_:FitmentInfo = null;
         if(!isChange)
         {
            return;
         }
         isChange = false;
         var _loc2_:int = int(usedList.length);
         var _loc3_:ByteArray = new ByteArray();
         for each(_loc1_ in usedList)
         {
            _loc3_.writeUnsignedInt(_loc1_.id);
            _loc3_.writeUnsignedInt(_loc1_.pos.x);
            _loc3_.writeUnsignedInt(_loc1_.pos.y);
            _loc3_.writeUnsignedInt(_loc1_.dir);
            _loc3_.writeUnsignedInt(_loc1_.status);
         }
         SocketConnection.send(CommandID.HEAD_SET_INFO,_loc2_,_loc3_);
      }
      
      public static function saveStyleType(param1:FitmentInfo, param2:Function) : void
      {
         var info:FitmentInfo = param1;
         var event:Function = param2;
         var byData:ByteArray = new ByteArray();
         byData.writeUnsignedInt(headquartersID);
         byData.writeUnsignedInt(info.id);
         byData.writeUnsignedInt(info.pos.x);
         byData.writeUnsignedInt(info.pos.y);
         byData.writeUnsignedInt(info.dir);
         byData.writeUnsignedInt(info.status);
         SocketConnection.addCmdListener(CommandID.HEAD_SET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.HEAD_SET_INFO,arguments.callee);
            event();
         });
         SocketConnection.send(CommandID.HEAD_SET_INFO,1,byData);
      }
      
      private static function onMove(param1:MouseEvent) : void
      {
         _isMove = true;
         var _loc2_:Point = new Point(DisplayObject(param1.currentTarget).mouseX,DisplayObject(param1.currentTarget).mouseY);
         _loc2_ = _loc2_.subtract(_offp);
         if(storagePanel.hitTestPoint(_loc2_.x,_loc2_.y))
         {
            _sprite.alpha = 1;
         }
         else
         {
            if(_info.type == SolidType.PUT)
            {
               if(_flomc.hitTestPoint(_loc2_.x,_loc2_.y,true))
               {
                  _isArrlowInMap = true;
                  _sprite.alpha = 1;
               }
               else
               {
                  _isArrlowInMap = false;
                  _sprite.alpha = 0.4;
               }
            }
            if(_info.type == SolidType.HANG)
            {
               if(_wapmc.hitTestPoint(_loc2_.x,_loc2_.y,true))
               {
                  _isArrlowInMap = true;
                  _sprite.alpha = 1;
               }
               else
               {
                  _isArrlowInMap = false;
                  _sprite.alpha = 0.4;
               }
            }
         }
      }
      
      private static function onUp(param1:MouseEvent) : void
      {
         MainManager.getStage().removeEventListener(MouseEvent.MOUSE_UP,onUp);
         MainManager.getStage().removeEventListener(MouseEvent.MOUSE_MOVE,onMove);
         var _loc2_:Point = new Point(DisplayObject(param1.currentTarget).mouseX,DisplayObject(param1.currentTarget).mouseY);
         _loc2_ = _loc2_.subtract(_offp);
         _sprite.stopDrag();
         if(storagePanel.hitTestPoint(_loc2_.x,_loc2_.y))
         {
            dragInStorage();
         }
         else if(MapManager.currentMap.root.hitTestPoint(_loc2_.x,_loc2_.y))
         {
            if(_isArrlowInMap)
            {
               dragInMap(_loc2_);
            }
            else
            {
               dragInNo();
            }
         }
         else
         {
            dragInNo();
         }
         _sprite = null;
         _parent = null;
         _info = null;
      }
      
      private static function dragInMap(param1:Point) : void
      {
         isChange = true;
         if(_type == DragTargetType.MAP)
         {
            if(_info.isFixed)
            {
               _info.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
            }
            else
            {
               _info.pos = param1;
            }
            _sprite.x = 0;
            _sprite.y = 0;
            _sprite.mouseEnabled = true;
            _sprite.mouseChildren = true;
            _parent.x = _info.pos.x;
            _parent.y = _info.pos.y;
            _parent.addChild(_sprite);
            DepthManager.swapDepth(_parent,_parent.y);
         }
         else
         {
            if(_info.isFixed)
            {
               _info.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
            }
            else
            {
               _info.pos = param1;
            }
            addInMap(_info);
            if(_type == DragTargetType.STORAGE)
            {
               DisplayUtil.removeForParent(_sprite);
               removeInStorage(_info.id);
            }
         }
      }
      
      private static function dragInStorage() : void
      {
         if(_type == DragTargetType.STORAGE)
         {
            if(_isMove)
            {
               DisplayUtil.removeForParent(_sprite);
               dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_STORAGE,_info));
            }
            else
            {
               isChange = true;
               if(_info.isFixed)
               {
                  _info.pos = MapXMLInfo.getHeadPos(MapManager.styleID);
               }
               else if(_info.type == SolidType.PUT)
               {
                  _info.pos = MapXMLInfo.getRoomDefaultFloPos(MapManager.styleID);
               }
               else if(_info.type == SolidType.HANG)
               {
                  _info.pos = MapXMLInfo.getRoomDefaultWapPos(MapManager.styleID);
               }
               else
               {
                  _info.pos = MainManager.getStageCenterPoint();
               }
               addInMap(_info);
               removeInStorage(_info.id);
               DisplayUtil.removeForParent(_sprite);
            }
         }
         else
         {
            addInStorage(_info);
            if(_type == DragTargetType.MAP)
            {
               isChange = true;
               DisplayUtil.removeForParent(_sprite);
               removeInMap(_info);
            }
         }
      }
      
      private static function dragInNo() : void
      {
         if(_type == DragTargetType.STORAGE)
         {
            DisplayUtil.removeForParent(_sprite);
            dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_STORAGE,_info));
            return;
         }
         _sprite.alpha = 1;
         _sprite.x = 0;
         _sprite.y = 0;
         _sprite.mouseEnabled = true;
         _parent.addChild(_sprite);
      }
      
      public static function getUsedInfo(param1:uint) : void
      {
         var teamID:uint = param1;
         SocketConnection.addCmdListener(CommandID.HEAD_GET_USED_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:HeadquarterInfo = null;
            var _loc4_:HeadquarterInfo = null;
            SocketConnection.removeCmdListener(CommandID.HEAD_GET_USED_INFO,arguments.callee);
            var _loc5_:Boolean = false;
            usedList = [];
            var _loc6_:ByteArray = param1.data as ByteArray;
            teamID = _loc6_.readUnsignedInt();
            headquartersID = _loc6_.readUnsignedInt();
            var _loc7_:uint = _loc6_.readUnsignedInt();
            var _loc8_:int = 0;
            while(_loc8_ < _loc7_)
            {
               _loc3_ = new HeadquarterInfo();
               FitmentInfo.setFor10008(_loc3_,_loc6_);
               usedList.push(_loc3_);
               if(_loc3_.type == SolidType.FRAME)
               {
                  MapManager.styleID = _loc3_.id;
                  _loc5_ = true;
               }
               _loc8_++;
            }
            if(!_loc5_)
            {
               _loc4_ = new HeadquarterInfo();
               MapManager.styleID = MapManager.defaultRoomStyleID;
               _loc4_.id = MapManager.defaultRoomStyleID;
               usedList.push(_loc4_);
            }
            dispatchEvent(new FitmentEvent(FitmentEvent.USED_LIST,null));
         });
         SocketConnection.send(CommandID.HEAD_GET_USED_INFO,teamID);
      }
      
      public static function addInMap(param1:FitmentInfo) : void
      {
         var _loc2_:HeadquarterInfo = new HeadquarterInfo();
         _loc2_.id = param1.id;
         _loc2_.pos = param1.pos.clone();
         _loc2_.dir = param1.dir;
         _loc2_.status = param1.status;
         usedList.push(_loc2_);
         dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_MAP,_loc2_));
      }
      
      public static function removeInMap(param1:FitmentInfo) : void
      {
         var _loc2_:int = int(usedList.indexOf(param1));
         if(_loc2_ != -1)
         {
            usedList.splice(_loc2_,1);
            dispatchEvent(new FitmentEvent(FitmentEvent.REMOVE_TO_MAP,param1));
         }
      }
      
      public static function removeAllInMap() : void
      {
         var f:FitmentInfo = null;
         usedList.forEach(function(param1:FitmentInfo, param2:int, param3:Array):void
         {
            var _loc4_:FitmentInfo = null;
            if(param1.type == SolidType.FRAME)
            {
               f = param1;
            }
            else
            {
               _loc4_ = storageMap.getValue(param1.id);
               if(Boolean(_loc4_))
               {
                  ++_loc4_.unUsedCount;
               }
               else
               {
                  param1.allCount = 1;
                  storageMap.add(param1.id,param1);
               }
            }
         });
         if(Boolean(f))
         {
            usedList = [f];
         }
         dispatchEvent(new FitmentEvent(FitmentEvent.REMOVE_ALL_TO_MAP,null));
         dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_STORAGE,null));
      }
      
      public static function getUsedList() : Array
      {
         return usedList;
      }
      
      public static function containsUsed(param1:uint) : Boolean
      {
         var id:uint = param1;
         return usedList.some(function(param1:FitmentInfo, param2:int, param3:Array):Boolean
         {
            if(id == param1.id)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function clearUsed() : void
      {
         usedList = [];
      }
      
      public static function getStorageInfo(param1:uint) : void
      {
         var teamID:uint = param1;
         SocketConnection.addCmdListener(CommandID.HEAD_GET_ALL_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:HeadquarterInfo = null;
            SocketConnection.removeCmdListener(CommandID.HEAD_GET_ALL_INFO,arguments.callee);
            storageMap.clear();
            var _loc4_:ByteArray = param1.data as ByteArray;
            teamID = _loc4_.readUnsignedInt();
            var _loc5_:int = int(_loc4_.readUnsignedInt());
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new HeadquarterInfo();
               FitmentInfo.setFor10007(_loc3_,_loc4_);
               storageMap.add(_loc3_.id,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new FitmentEvent(FitmentEvent.STORAGE_LIST,null));
         });
         SocketConnection.send(CommandID.HEAD_GET_ALL_INFO,teamID);
      }
      
      public static function addInStorage(param1:FitmentInfo) : void
      {
         var _loc2_:FitmentInfo = storageMap.getValue(param1.id);
         if(Boolean(_loc2_))
         {
            ++_loc2_.unUsedCount;
            dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_STORAGE,_loc2_));
         }
         else
         {
            param1.allCount = 1;
            storageMap.add(param1.id,param1);
            dispatchEvent(new FitmentEvent(FitmentEvent.ADD_TO_STORAGE,param1));
         }
      }
      
      public static function removeInStorage(param1:uint) : void
      {
         var _loc2_:FitmentInfo = storageMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            if(_loc2_.unUsedCount > 1)
            {
               --_loc2_.allCount;
            }
            else
            {
               storageMap.remove(param1);
            }
            dispatchEvent(new FitmentEvent(FitmentEvent.REMOVE_TO_STORAGE,_loc2_));
         }
      }
      
      public static function getAllList() : Array
      {
         return storageMap.getValues();
      }
      
      public static function getUnUsedList() : Array
      {
         var data:Array = storageMap.getValues();
         return data.filter(function(param1:FitmentInfo, param2:int, param3:Array):Boolean
         {
            if(param1.unUsedCount > 0)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function getUsedListForAll() : Array
      {
         var data:Array = storageMap.getValues();
         return data.filter(function(param1:FitmentInfo, param2:int, param3:Array):Boolean
         {
            if(param1.usedCount > 0)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function getUnUsedListForType(param1:uint) : Array
      {
         var t:uint = param1;
         var data:Array = storageMap.getValues();
         return data.filter(function(param1:FitmentInfo, param2:int, param3:Array):Boolean
         {
            if(param1.unUsedCount > 0)
            {
               if(param1.type == t)
               {
                  return true;
               }
            }
            return false;
         });
      }
      
      public static function containsStorage(param1:uint) : Boolean
      {
         var _loc2_:FitmentInfo = storageMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            if(_loc2_.unUsedCount > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function containsAll(param1:uint) : Boolean
      {
         return storageMap.containsKey(param1);
      }
      
      public static function clearAll() : void
      {
         return storageMap.clear();
      }
      
      public static function destroy() : void
      {
         _sprite = null;
         _parent = null;
         _info = null;
         storagePanel = null;
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            getInstance().dispatchEvent(param1);
         }
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function willTrigger(param1:String) : Boolean
      {
         return getInstance().willTrigger(param1);
      }
   }
}

