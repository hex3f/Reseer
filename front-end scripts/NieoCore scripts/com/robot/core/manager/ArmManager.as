package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.event.ArmEvent;
   import com.robot.core.info.team.ArmInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
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
   
   public class ArmManager
   {
      
      public static var isChange:Boolean;
      
      public static var isChangeForUpgrade:Boolean;
      
      public static var storagePanel:Sprite;
      
      public static var teamID:uint;
      
      public static var headquartersID:uint;
      
      private static var _sprite:Sprite;
      
      private static var _info:ArmInfo;
      
      private static var _parent:DisplayObjectContainer;
      
      private static var _type:int;
      
      private static var _offp:Point;
      
      private static var _flomc:DisplayObject;
      
      private static var _isMove:Boolean;
      
      private static var _instance:EventDispatcher;
      
      private static var _isArrlowInMap:Boolean = true;
      
      private static var _usedList:Array = [];
      
      private static var _allMap:HashMap = new HashMap();
      
      private static var _upUsedList:Array = [];
      
      private static var _upAllMap:HashMap = new HashMap();
      
      public function ArmManager()
      {
         super();
      }
      
      public static function getMax() : uint
      {
         return 15;
      }
      
      public static function get dragInMapEnabled() : Boolean
      {
         if(_upUsedList.length < getMax())
         {
            return true;
         }
         return false;
      }
      
      public static function doDrag(param1:Sprite, param2:ArmInfo, param3:DisplayObjectContainer, param4:int, param5:Point = null) : void
      {
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
         var _loc6_:Point = DisplayUtil.localToLocal(_sprite,MainManager.getStage());
         _sprite.x = _loc6_.x;
         _sprite.y = _loc6_.y;
         MainManager.getStage().addChild(_sprite);
         MainManager.getStage().addEventListener(MouseEvent.MOUSE_UP,onUp);
         MainManager.getStage().addEventListener(MouseEvent.MOUSE_MOVE,onMove);
         var _loc7_:Rectangle = _sprite.getRect(_sprite);
         _sprite.startDrag(false,new Rectangle(-_loc7_.x,-_loc7_.y,MainManager.getStageWidth() - _loc7_.width,MainManager.getStageHeight() - _loc7_.height));
         _isMove = false;
         if(Boolean(MapManager.currentMap.animatorLevel))
         {
            _flomc = MapManager.currentMap.animatorLevel.getChildByName("floMC");
         }
      }
      
      public static function setIsChange(param1:ArmInfo = null) : void
      {
         if(param1 == null)
         {
            param1 = _info;
         }
         if(param1.buyTime == 0)
         {
            isChange = true;
         }
         else
         {
            isChangeForUpgrade = true;
         }
      }
      
      public static function saveInfo() : void
      {
         var _loc1_:ArmInfo = null;
         var _loc2_:int = 0;
         var _loc3_:ByteArray = null;
         var _loc4_:int = 0;
         var _loc5_:ByteArray = null;
         if(isChange)
         {
            isChange = false;
            _loc2_ = int(_usedList.length);
            _loc3_ = new ByteArray();
            _loc3_.writeUnsignedInt(_loc2_);
            for each(_loc1_ in _usedList)
            {
               _loc3_.writeUnsignedInt(_loc1_.id);
               _loc3_.writeUnsignedInt(_loc1_.pos.x);
               _loc3_.writeUnsignedInt(_loc1_.pos.y);
               _loc3_.writeUnsignedInt(_loc1_.dir);
               _loc3_.writeUnsignedInt(_loc1_.status);
            }
            SocketConnection.send(CommandID.ARM_SET_INFO,_loc3_);
         }
         _loc1_ = null;
         if(isChangeForUpgrade)
         {
            isChangeForUpgrade = false;
            _loc4_ = _upUsedList.length - 1;
            _loc5_ = new ByteArray();
            _loc5_.writeUnsignedInt(_loc4_);
            for each(_loc1_ in _upUsedList)
            {
               if(_loc1_.id != 1)
               {
                  _loc5_.writeUnsignedInt(_loc1_.id);
                  _loc5_.writeUnsignedInt(_loc1_.buyTime);
                  _loc5_.writeUnsignedInt(_loc1_.pos.x);
                  _loc5_.writeUnsignedInt(_loc1_.pos.y);
                  _loc5_.writeUnsignedInt(_loc1_.dir);
                  _loc5_.writeUnsignedInt(_loc1_.status);
               }
            }
            SocketConnection.send(CommandID.ARM_UP_SET_INFO,_loc5_);
         }
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
         else if(_flomc.hitTestPoint(_loc2_.x,_loc2_.y,true))
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
         setIsChange();
         if(_type == DragTargetType.MAP)
         {
            _info.pos = param1;
            _sprite.x = 0;
            _sprite.y = 0;
            _sprite.mouseEnabled = true;
            _sprite.mouseChildren = true;
            _parent.x = param1.x;
            _parent.y = param1.y;
            _parent.addChild(_sprite);
            DepthManager.swapDepth(_parent,_parent.y);
         }
         else
         {
            _info.pos = param1;
            addInMap(_info);
            if(_type == DragTargetType.STORAGE)
            {
               DisplayUtil.removeForParent(_sprite);
               removeInStorage(_info);
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
               dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_STORAGE,_info));
            }
            else
            {
               setIsChange();
               if(_info.type == SolidType.PUT)
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
               removeInStorage(_info);
               DisplayUtil.removeForParent(_sprite);
            }
         }
         else
         {
            addInStorage(_info);
            if(_type == DragTargetType.MAP)
            {
               setIsChange();
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
            return;
         }
         _sprite.alpha = 1;
         _sprite.x = 0;
         _sprite.y = 0;
         _sprite.mouseEnabled = true;
         _parent.addChild(_sprite);
      }
      
      public static function getUsedInfoForServer(param1:uint) : void
      {
         var tID:uint = param1;
         SocketConnection.addCmdListener(CommandID.ARM_GET_USED_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:ArmInfo = null;
            var _loc4_:ArmInfo = null;
            SocketConnection.removeCmdListener(CommandID.ARM_GET_USED_INFO,arguments.callee);
            var _loc5_:Boolean = false;
            _usedList = [];
            var _loc6_:ByteArray = param1.data as ByteArray;
            teamID = _loc6_.readUnsignedInt();
            headquartersID = _loc6_.readUnsignedInt();
            var _loc7_:uint = _loc6_.readUnsignedInt();
            var _loc8_:int = 0;
            while(_loc8_ < _loc7_)
            {
               _loc3_ = new ArmInfo();
               ArmInfo.setFor2941(_loc3_,_loc6_);
               if(_loc3_.type == SolidType.FRAME)
               {
                  MapManager.styleID = _loc3_.id;
                  _loc5_ = true;
               }
               else
               {
                  _usedList.push(_loc3_);
               }
               _loc8_++;
            }
            if(!_loc5_)
            {
               _loc4_ = new ArmInfo();
               MapManager.styleID = MapManager.defaultArmStyleID;
               _loc4_.id = MapManager.styleID;
               _usedList.push(_loc4_);
            }
            dispatchEvent(new ArmEvent(ArmEvent.USED_LIST,null));
         });
         SocketConnection.send(CommandID.ARM_GET_USED_INFO,tID);
      }
      
      public static function getUsedInfoForServer_Up(param1:uint) : void
      {
         var tID:uint = param1;
         SocketConnection.addCmdListener(CommandID.ARM_UP_GET_USED_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:ArmInfo = null;
            SocketConnection.removeCmdListener(CommandID.ARM_UP_GET_USED_INFO,arguments.callee);
            _upUsedList = [];
            var _loc4_:ByteArray = param1.data as ByteArray;
            teamID = _loc4_.readUnsignedInt();
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new ArmInfo();
               ArmInfo.setFor2967_2965(_loc3_,_loc4_);
               _loc3_.isUsed = true;
               _upUsedList.push(_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ArmEvent(ArmEvent.UP_USED_LIST,null));
         });
         SocketConnection.send(CommandID.ARM_UP_GET_USED_INFO,tID);
      }
      
      public static function addInMap(param1:ArmInfo) : void
      {
         var _loc2_:ArmInfo = param1.clone();
         if(_loc2_.buyTime == 0)
         {
            _usedList.push(_loc2_);
         }
         else
         {
            _loc2_.isUsed = true;
            _upUsedList.push(_loc2_);
         }
         dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_MAP,_loc2_));
      }
      
      public static function removeInMap(param1:ArmInfo) : void
      {
         var _loc2_:int = 0;
         if(param1.buyTime == 0)
         {
            _loc2_ = int(_usedList.indexOf(param1));
            if(_loc2_ != -1)
            {
               _usedList.splice(_loc2_,1);
               dispatchEvent(new ArmEvent(ArmEvent.REMOVE_TO_MAP,param1));
            }
         }
         else
         {
            _loc2_ = int(_upUsedList.indexOf(param1));
            if(_loc2_ != -1)
            {
               _upUsedList.splice(_loc2_,1);
               dispatchEvent(new ArmEvent(ArmEvent.REMOVE_TO_MAP,param1));
            }
         }
      }
      
      public static function removeAllInMap() : void
      {
         var f:ArmInfo = null;
         var uh:ArmInfo = null;
         _usedList.forEach(function(param1:ArmInfo, param2:int, param3:Array):void
         {
            var _loc4_:ArmInfo = null;
            if(param1.type == SolidType.FRAME)
            {
               f = param1;
            }
            else
            {
               _loc4_ = _allMap.getValue(param1.id);
               if(Boolean(_loc4_))
               {
                  ++_loc4_.unUsedCount;
               }
               else
               {
                  param1.allCount = 1;
                  _allMap.add(param1.id,param1);
               }
            }
         });
         if(Boolean(f))
         {
            _usedList = [f];
         }
         _upUsedList.forEach(function(param1:ArmInfo, param2:int, param3:Array):void
         {
            if(param1.type == SolidType.HEAD)
            {
               uh = param1;
            }
            else
            {
               param1.isUsed = false;
               _upAllMap.add(param1.buyTime,param1);
            }
         });
         if(Boolean(uh))
         {
            _upUsedList = [uh];
         }
         dispatchEvent(new ArmEvent(ArmEvent.REMOVE_ALL_TO_MAP,null));
         dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_STORAGE,null));
      }
      
      public static function getUsedList() : Array
      {
         return _usedList;
      }
      
      public static function getUsedList_Up() : Array
      {
         return _upUsedList;
      }
      
      public static function containsUsed(param1:uint) : Boolean
      {
         var _loc2_:ArmInfo = null;
         for each(_loc2_ in _usedList)
         {
            if(param1 == _loc2_.id)
            {
               return true;
            }
         }
         _loc2_ = null;
         for each(_loc2_ in _upUsedList)
         {
            if(param1 == _loc2_.id)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getAllInfoForServer(param1:uint) : void
      {
         var tid:uint = param1;
         SocketConnection.addCmdListener(CommandID.ARM_GET_ALL_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:ArmInfo = null;
            SocketConnection.removeCmdListener(CommandID.ARM_GET_ALL_INFO,arguments.callee);
            _allMap.clear();
            var _loc4_:ByteArray = param1.data as ByteArray;
            teamID = _loc4_.readUnsignedInt();
            var _loc5_:int = int(_loc4_.readUnsignedInt());
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new ArmInfo();
               ArmInfo.setFor2942(_loc3_,_loc4_);
               _allMap.add(_loc3_.id,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ArmEvent(ArmEvent.ALL_LIST,null));
         });
         SocketConnection.send(CommandID.ARM_GET_ALL_INFO,tid);
      }
      
      public static function getAllInfoForServer_Up(param1:uint) : void
      {
         var tid:uint = param1;
         SocketConnection.addCmdListener(CommandID.ARM_UP_GET_ALL_INFO,function(param1:SocketEvent):void
         {
            var _loc3_:ArmInfo = null;
            SocketConnection.removeCmdListener(CommandID.ARM_UP_GET_ALL_INFO,arguments.callee);
            _upAllMap.clear();
            var _loc4_:ByteArray = param1.data as ByteArray;
            teamID = _loc4_.readUnsignedInt();
            var _loc5_:int = int(_loc4_.readUnsignedInt());
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new ArmInfo();
               ArmInfo.setFor2966(_loc3_,_loc4_);
               _upAllMap.add(_loc3_.buyTime,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ArmEvent(ArmEvent.UP_ALL_LIST,null));
         });
         SocketConnection.send(CommandID.ARM_UP_GET_ALL_INFO,tid);
      }
      
      public static function addInStorage(param1:ArmInfo) : void
      {
         var _loc2_:ArmInfo = null;
         if(param1.buyTime == 0)
         {
            _loc2_ = _allMap.getValue(param1.id);
            if(Boolean(_loc2_))
            {
               ++_loc2_.unUsedCount;
               dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_STORAGE,_loc2_));
            }
            else
            {
               param1.allCount = 1;
               _allMap.add(param1.id,param1);
               dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_STORAGE,param1));
            }
         }
         else
         {
            param1.isUsed = false;
            _upAllMap.add(param1.buyTime,param1);
            dispatchEvent(new ArmEvent(ArmEvent.ADD_TO_STORAGE,param1));
         }
      }
      
      public static function removeInStorage(param1:ArmInfo) : void
      {
         var _loc2_:ArmInfo = null;
         if(param1.buyTime == 0)
         {
            _loc2_ = _allMap.getValue(param1.id);
            if(Boolean(_loc2_))
            {
               if(_loc2_.unUsedCount > 1)
               {
                  --_loc2_.allCount;
               }
               else
               {
                  _allMap.remove(_loc2_.id);
               }
               dispatchEvent(new ArmEvent(ArmEvent.REMOVE_TO_STORAGE,_loc2_));
            }
         }
         else if(_upAllMap.remove(param1.buyTime))
         {
            dispatchEvent(new ArmEvent(ArmEvent.REMOVE_TO_STORAGE,param1));
         }
      }
      
      public static function getAllList() : Array
      {
         return _allMap.getValues().concat(_upAllMap.getValues());
      }
      
      public static function getUnUsedList() : Array
      {
         var arr:Array = null;
         arr = null;
         arr = [];
         _allMap.eachValue(function(param1:ArmInfo):void
         {
            if(param1.unUsedCount > 0)
            {
               arr.push(param1);
            }
         });
         _upAllMap.eachValue(function(param1:ArmInfo):void
         {
            if(!param1.isUsed)
            {
               arr.push(param1);
            }
         });
         return arr;
      }
      
      public static function getUsedListForAll() : Array
      {
         var arr:Array = null;
         arr = null;
         arr = [];
         _allMap.eachValue(function(param1:ArmInfo):void
         {
            if(param1.usedCount > 0)
            {
               arr.push(param1);
            }
         });
         return arr;
      }
      
      public static function getUnUsedListForType(param1:uint) : Array
      {
         var arr:Array = null;
         var t:uint = param1;
         arr = null;
         arr = [];
         if(t == SolidType.FRAME || t == SolidType.PUT)
         {
            _allMap.eachValue(function(param1:ArmInfo):void
            {
               if(param1.unUsedCount > 0)
               {
                  if(param1.type == t)
                  {
                     arr.push(param1);
                  }
               }
            });
         }
         else
         {
            _upAllMap.eachValue(function(param1:ArmInfo):void
            {
               if(param1.type == t)
               {
                  if(!param1.isUsed)
                  {
                     arr.push(param1);
                  }
               }
            });
         }
         return arr;
      }
      
      public static function containsStorage(param1:uint) : Boolean
      {
         var _loc2_:ArmInfo = _allMap.getValue(param1);
         if(Boolean(_loc2_))
         {
            if(_loc2_.unUsedCount > 0)
            {
               return true;
            }
         }
         _loc2_ = null;
         var _loc3_:Array = _upAllMap.getValues();
         for each(_loc2_ in _loc3_)
         {
            if(_loc2_.id == param1)
            {
               if(!_loc2_.isUsed)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function containsAll(param1:uint) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:ArmInfo = null;
         if(_allMap.containsKey(param1))
         {
            return true;
         }
         _loc2_ = _upAllMap.getValues();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_.id == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function destroy() : void
      {
         _sprite = null;
         _parent = null;
         _info = null;
         storagePanel = null;
         _flomc = null;
      }
      
      public static function getContributeBounds(param1:Function = null) : void
      {
         var func:Function = param1;
         SocketConnection.addCmdListener(CommandID.Get_CONTRIBUTE_BOUNDS,function(param1:SocketEvent):void
         {
            var _loc3_:* = 0;
            var _loc4_:* = 0;
            SocketConnection.removeCmdListener(CommandID.Get_CONTRIBUTE_BOUNDS,arguments.callee);
            var _loc5_:ByteArray = param1.data as ByteArray;
            var _loc6_:uint = _loc5_.readUnsignedInt();
            if(_loc6_ > 0)
            {
               _loc5_.readUnsignedInt();
               _loc3_ = _loc5_.readUnsignedInt();
               _loc4_ = _loc5_.readUnsignedInt();
               MainManager.actorInfo.teamInfo.canExContribution -= _loc6_ * 10;
               if(MainManager.actorInfo.teamInfo.canExContribution < 0)
               {
                  MainManager.actorInfo.teamInfo.canExContribution = 0;
               }
               MainManager.actorInfo.coins += _loc3_;
               if(func != null)
               {
                  func();
               }
               Alarm.show("祝贺你领取到了战队贡献奖励：\n" + _loc4_ + "积累经验\n" + _loc3_ + "赛尔豆\n你的功绩将会在战队成员间传诵！");
            }
         });
         SocketConnection.send(CommandID.Get_CONTRIBUTE_BOUNDS);
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

