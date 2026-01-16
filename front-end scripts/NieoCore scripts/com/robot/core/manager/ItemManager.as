package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.info.userItem.SoulBeadItemInfo;
   import com.robot.core.net.SocketConnection;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   [Event(name="clothList",type="com.robot.core.event.ItemEvent")]
   [Event(name="collectionList",type="com.robot.core.event.ItemEvent")]
   [Event(name="throwList",type="com.robot.core.event.ItemEvent")]
   [Event(name="petItemList",type="com.robot.core.event.ItemEvent")]
   public class ItemManager
   {
      
      private static var _instance:EventDispatcher;
      
      private static var _clothMap:HashMap = new HashMap();
      
      private static var _collectionMap:HashMap = new HashMap();
      
      private static var _throwMap:HashMap = new HashMap();
      
      private static var _petItemMap:HashMap = new HashMap();
      
      private static var _soulBeadMap:HashMap = new HashMap();
      
      private static var _superMap:HashMap = new HashMap();
      
      public function ItemManager()
      {
         super();
      }
      
      public static function containsAll(param1:uint) : Boolean
      {
         if(_clothMap.containsKey(param1))
         {
            return true;
         }
         if(_collectionMap.containsKey(param1))
         {
            return true;
         }
         return false;
      }
      
      public static function getInfo(param1:uint) : SingleItemInfo
      {
         var _loc2_:SingleItemInfo = _clothMap.getValue(param1);
         if(_loc2_ == null)
         {
            _loc2_ = _collectionMap.getValue(param1);
         }
         return _loc2_;
      }
      
      public static function getCloth(param1:Function = null) : void
      {
         var callback:Function = null;
         callback = param1;
         _clothMap.clear();
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,function(param1:SocketEvent):void
         {
            var e:SocketEvent = param1;
            SocketConnection.removeCmdListener(CommandID.ITEM_LIST,arguments.callee);
            addClothMap(e.data as ByteArray);
            SocketConnection.addCmdListener(CommandID.ITEM_LIST,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.ITEM_LIST,arguments.callee);
               addClothMap(param1.data as ByteArray);
               dispatchEvent(new ItemEvent(ItemEvent.CLOTH_LIST));
               if(null != callback)
               {
                  callback();
               }
            });
            SocketConnection.send(CommandID.ITEM_LIST,1300001,1400000,2);
         });
         SocketConnection.send(CommandID.ITEM_LIST,100001,101000,2);
      }
      
      private static function addClothMap(param1:ByteArray) : void
      {
         var _loc2_:SingleItemInfo = null;
         param1.position = 0;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = new SingleItemInfo(param1);
            _clothMap.add(_loc2_.itemID,_loc2_);
            _loc4_++;
         }
      }
      
      public static function containsCloth(param1:uint) : Boolean
      {
         return _clothMap.containsKey(param1);
      }
      
      public static function getClothInfo(param1:uint) : SingleItemInfo
      {
         return _clothMap.getValue(param1);
      }
      
      public static function getClothIDs() : Array
      {
         return _clothMap.getKeys();
      }
      
      public static function getClothInfos() : Array
      {
         return _clothMap.getValues();
      }
      
      public static function upDateCloth(param1:uint) : void
      {
         var id:uint = param1;
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,function(param1:SocketEvent):void
         {
            var _loc3_:SingleItemInfo = null;
            SocketConnection.removeCmdListener(CommandID.ITEM_LIST,arguments.callee);
            var _loc4_:ByteArray = param1.data as ByteArray;
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new SingleItemInfo(_loc4_);
               _clothMap.add(_loc3_.itemID,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ItemEvent(ItemEvent.CLOTH_LIST));
         });
         SocketConnection.send(CommandID.ITEM_LIST,id,id,2);
      }
      
      private static function onClothList(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onClothList);
         _clothMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _clothMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.CLOTH_LIST));
      }
      
      public static function getCollection() : void
      {
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,onCollectionList);
         SocketConnection.send(CommandID.ITEM_LIST,300001,500000,2);
      }
      
      public static function containsCollection(param1:uint) : Boolean
      {
         return _collectionMap.containsKey(param1);
      }
      
      public static function getCollectionInfo(param1:uint) : SingleItemInfo
      {
         return _collectionMap.getValue(param1);
      }
      
      public static function getCollectionIDs() : Array
      {
         return _collectionMap.getKeys();
      }
      
      public static function getCollectionInfos() : Array
      {
         return _collectionMap.getValues();
      }
      
      public static function upDateCollection(param1:uint) : void
      {
         var id:uint = param1;
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,function(param1:SocketEvent):void
         {
            var _loc3_:SingleItemInfo = null;
            SocketConnection.removeCmdListener(CommandID.ITEM_LIST,arguments.callee);
            var _loc4_:ByteArray = param1.data as ByteArray;
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new SingleItemInfo(_loc4_);
               _collectionMap.add(_loc3_.itemID,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ItemEvent(ItemEvent.COLLECTION_LIST));
         });
         SocketConnection.send(CommandID.ITEM_LIST,id,id,2);
      }
      
      private static function onCollectionList(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onCollectionList);
         _collectionMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _collectionMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.COLLECTION_LIST));
      }
      
      public static function getThrowThing() : void
      {
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,onThrowList);
         SocketConnection.send(CommandID.ITEM_LIST,600001,600100,2);
      }
      
      private static function onThrowList(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onThrowList);
         _throwMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _throwMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.THROW_LIST));
      }
      
      public static function containsThrow(param1:uint) : Boolean
      {
         return _throwMap.containsKey(param1);
      }
      
      public static function getThrowInfo(param1:uint) : SingleItemInfo
      {
         return _throwMap.getValue(param1);
      }
      
      public static function getThrowIDs() : Array
      {
         return _throwMap.getKeys();
      }
      
      public static function getPetItem() : void
      {
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,onPetItemList);
         SocketConnection.send(CommandID.ITEM_LIST,300011,300250,2);
      }
      
      private static function onPetItemList(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onPetItemList);
         _petItemMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _petItemMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,onPetItemList2);
         SocketConnection.send(CommandID.ITEM_LIST,300601,300700,2);
      }
      
      private static function onPetItemList2(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onPetItemList2);
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _petItemMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.PET_ITEM_LIST));
      }
      
      public static function containsPetItem(param1:uint) : Boolean
      {
         return _petItemMap.containsKey(param1);
      }
      
      public static function getPetItemInfo(param1:uint) : SingleItemInfo
      {
         return _petItemMap.getValue(param1);
      }
      
      public static function getPetItemIDs() : Array
      {
         return _petItemMap.getKeys();
      }
      
      public static function getSoulBead() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_SOUL_BEAD_List,onSoulBeadList);
         SocketConnection.send(CommandID.GET_SOUL_BEAD_List);
      }
      
      private static function onSoulBeadList(param1:SocketEvent) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:SoulBeadItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.GET_SOUL_BEAD_List,arguments.callee);
         _soulBeadMap.clear();
         var _loc6_:ByteArray = param1.data as ByteArray;
         var _loc7_:uint = _loc6_.readUnsignedInt();
         var _loc8_:Number = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = _loc6_.readUnsignedInt();
            _loc4_ = _loc6_.readUnsignedInt();
            _loc5_ = new SoulBeadItemInfo();
            _loc5_.obtainTime = _loc3_;
            _loc5_.itemID = _loc4_;
            _soulBeadMap.add(_loc3_,_loc5_);
            _loc8_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.SOULBEAD_ITEM_LIST));
      }
      
      public static function containsSoulBead(param1:uint) : Boolean
      {
         return _soulBeadMap.containsKey(param1);
      }
      
      public static function getSoulBeadInfo(param1:uint) : SoulBeadItemInfo
      {
         return _soulBeadMap.getValue(param1);
      }
      
      public static function getSBObtainTms() : Array
      {
         return _soulBeadMap.getKeys();
      }
      
      public static function getSoulBeadInfos() : Array
      {
         return _soulBeadMap.getValues();
      }
      
      public static function getSuper() : void
      {
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,onSuperList);
         SocketConnection.send(CommandID.ITEM_LIST,100001,500000,2);
      }
      
      public static function containsSuper(param1:uint) : Boolean
      {
         return _superMap.containsKey(param1);
      }
      
      public static function getSuperInfo(param1:uint) : SingleItemInfo
      {
         return _superMap.getValue(param1);
      }
      
      public static function getSuperIDs() : Array
      {
         return _superMap.getKeys();
      }
      
      public static function getSuperInfos() : Array
      {
         return _superMap.getValues();
      }
      
      public static function upDateSuper(param1:uint) : void
      {
         var id:uint = param1;
         SocketConnection.addCmdListener(CommandID.ITEM_LIST,function(param1:SocketEvent):void
         {
            var _loc3_:SingleItemInfo = null;
            SocketConnection.removeCmdListener(CommandID.ITEM_LIST,arguments.callee);
            var _loc4_:ByteArray = param1.data as ByteArray;
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new SingleItemInfo(_loc4_);
               _superMap.add(_loc3_.itemID,_loc3_);
               _loc6_++;
            }
            dispatchEvent(new ItemEvent(ItemEvent.SUPER_ITEM_LIST));
         });
         SocketConnection.send(CommandID.ITEM_LIST,id,id,2);
      }
      
      private static function onSuperList(param1:SocketEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         SocketConnection.removeCmdListener(CommandID.ITEM_LIST,onSuperList);
         _superMap.clear();
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new SingleItemInfo(_loc3_);
            _superMap.add(_loc2_.itemID,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new ItemEvent(ItemEvent.SUPER_ITEM_LIST));
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
         getInstance().dispatchEvent(param1);
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
   }
}

