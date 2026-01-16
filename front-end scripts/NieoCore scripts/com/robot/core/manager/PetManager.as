package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.info.pet.ExeingPetInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetListInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.info.pet.PetTakeOutInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   
   [Event(name="added",type="com.robot.core.event.PetEvent")]
   [Event(name="removed",type="com.robot.core.event.PetEvent")]
   [Event(name="setDefault",type="com.robot.core.event.PetEvent")]
   [Event(name="cureComplete",type="com.robot.core.event.PetEvent")]
   [Event(name="cureOneComplete",type="com.robot.core.event.PetEvent")]
   [Event(name="updateInfo",type="com.robot.core.event.PetEvent")]
   [Event(name="storageUpdateInfo",type="com.robot.core.event.PetEvent")]
   [Event(name="storageAdded",type="com.robot.core.event.PetEvent")]
   [Event(name="storageRemoved",type="com.robot.core.event.PetEvent")]
   [Event(name="storageList",type="com.robot.core.event.PetEvent")]
   public class PetManager
   {
      
      public static var defaultTime:uint;
      
      public static var currentShowCatchTime:uint;
      
      public static var handleCatchTime:uint;
      
      private static var _isgetdata:Boolean;
      
      private static var _curEndPetInfo:PetInfo;
      
      private static var curRoweiPetInfo:PetListInfo;
      
      private static var curRetrievePetInfo:PetListInfo;
      
      private static var _instance:EventDispatcher;
      
      private static var _handler:Function;
      
      private static var _bagMap:HashMap = new HashMap();
      
      public static var novicePet:uint = 0;
      
      public static var npcPet:uint = 0;
      
      public static var showInfo:PetInfo = null;
      
      private static var b:Boolean = true;
      
      private static var _storageMap:HashMap = new HashMap();
      
      private static var _exePetListMap:HashMap = new HashMap();
      
      private static var roweiPetMap:HashMap = new HashMap();
      
      public function PetManager()
      {
         super();
      }
      
      public static function checkHandlePet(param1:uint) : void
      {
         if(handleCatchTime > 0)
         {
            _bagMap.remove(handleCatchTime);
            _bagMap.add(param1,null);
            upDate();
            handleCatchTime = 0;
         }
      }
      
      public static function initData(param1:IDataInput, param2:uint) : void
      {
         var _loc3_:PetInfo = null;
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc3_ = new PetInfo(param1);
            if(_loc4_ == 0)
            {
               _loc3_.isDefault = true;
               defaultTime = _loc3_.catchTime;
            }
            _bagMap.add(_loc3_.catchTime,_loc3_);
            _loc4_++;
         }
      }
      
      public static function upDate() : void
      {
         var ts:Array = null;
         ts = null;
         var upLoop:Function = function(param1:int):void
         {
            var catchTime:uint = 0;
            var i:int = param1;
            if(i == length)
            {
               dispatchEvent(new PetEvent(PetEvent.UPDATE_INFO,0));
               ts = null;
               b = true;
               return;
            }
            catchTime = uint(ts[i]);
            SocketConnection.addCmdListener(CommandID.GET_PET_INFO,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,arguments.callee);
               var _loc3_:PetInfo = param1.data as PetInfo;
               if(_loc3_.catchTime == defaultTime)
               {
                  _loc3_.isDefault = true;
               }
               if(containsBagForCapTime(_loc3_.catchTime))
               {
                  _bagMap.add(_loc3_.catchTime,_loc3_);
               }
               ++i;
               upLoop(i);
            });
            SocketConnection.send(CommandID.GET_PET_INFO,catchTime);
         };
         if(!b)
         {
            return;
         }
         b = false;
         ts = catchTimes;
         upLoop(0);
      }
      
      public static function add(param1:PetInfo) : void
      {
         if(_bagMap.length >= 6)
         {
            addStorage(param1.id,param1.catchTime);
            return;
         }
         if(_bagMap.length == 0)
         {
            param1.isDefault = true;
            defaultTime = param1.catchTime;
         }
         _bagMap.add(param1.catchTime,param1);
         dispatchEvent(new PetEvent(PetEvent.ADDED,param1.catchTime));
      }
      
      public static function remove(param1:uint) : PetInfo
      {
         var _loc2_:PetInfo = _bagMap.remove(param1);
         if(Boolean(_loc2_))
         {
            if(Boolean(showInfo))
            {
               if(showInfo.catchTime == param1)
               {
                  showInfo = null;
               }
            }
            dispatchEvent(new PetEvent(PetEvent.REMOVED,param1));
            return _loc2_;
         }
         return null;
      }
      
      public static function deletePet(param1:uint) : void
      {
         _bagMap.remove(param1);
         _storageMap.remove(param1);
      }
      
      public static function containsBagForID(param1:uint) : Boolean
      {
         var id:uint = param1;
         var arr:Array = _bagMap.getValues();
         return arr.some(function(param1:PetInfo, param2:int, param3:Array):Boolean
         {
            if(id == param1.id)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function containsBagForCapTime(param1:uint) : Boolean
      {
         var cap:uint = param1;
         var arr:Array = _bagMap.getValues();
         return arr.some(function(param1:PetInfo, param2:int, param3:Array):Boolean
         {
            if(cap == param1.catchTime)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function getPetInfo(param1:uint) : PetInfo
      {
         return _bagMap.getValue(param1);
      }
      
      public static function get length() : uint
      {
         return _bagMap.length;
      }
      
      public static function get catchTimes() : Array
      {
         return _bagMap.getKeys();
      }
      
      public static function get infos() : Array
      {
         return _bagMap.getValues();
      }
      
      public static function setIn(param1:uint, param2:uint, param3:uint = 0) : void
      {
         var catchTime:uint = param1;
         var flag:uint = param2;
         var id:uint = param3;
         SocketConnection.addCmdListener(CommandID.PET_RELEASE,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.PET_RELEASE,arguments.callee);
            var _loc3_:PetTakeOutInfo = param1.data as PetTakeOutInfo;
            if(_loc3_.flag == 1)
            {
               add(_loc3_.petInfo);
            }
            else
            {
               addStorage(id,catchTime);
            }
            _setDefault(_loc3_.firstPetTime);
         });
         SocketConnection.send(CommandID.PET_RELEASE,catchTime,flag);
      }
      
      public static function bagToInStorage(param1:uint) : void
      {
         var catchTime:uint = param1;
         SocketConnection.addCmdListener(CommandID.PET_RELEASE,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.PET_RELEASE,arguments.callee);
            var _loc3_:PetTakeOutInfo = param1.data as PetTakeOutInfo;
            var _loc4_:PetInfo = remove(catchTime);
            if(Boolean(_loc4_))
            {
               addStorage(_loc4_.id,_loc4_.catchTime);
            }
            _setDefault(_loc3_.firstPetTime);
         });
         SocketConnection.send(CommandID.PET_RELEASE,catchTime,0);
      }
      
      public static function storageToInBag(param1:uint) : void
      {
         var catchTime:uint = param1;
         SocketConnection.addCmdListener(CommandID.PET_RELEASE,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.PET_RELEASE,arguments.callee);
            var _loc3_:PetTakeOutInfo = param1.data as PetTakeOutInfo;
            removeStorage(catchTime);
            add(_loc3_.petInfo);
            _setDefault(_loc3_.firstPetTime);
         });
         SocketConnection.send(CommandID.PET_RELEASE,catchTime,1);
      }
      
      public static function setDefault(param1:uint, param2:Boolean = true) : void
      {
         var catchTime:uint = param1;
         var isNet:Boolean = param2;
         if(defaultTime == catchTime)
         {
            return;
         }
         if(isNet)
         {
            SocketConnection.addCmdListener(CommandID.PET_DEFAULT,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.PET_DEFAULT,arguments.callee);
               _setDefault(catchTime);
            });
            SocketConnection.send(CommandID.PET_DEFAULT,catchTime);
         }
         else
         {
            _setDefault(catchTime);
         }
      }
      
      private static function _setDefault(param1:uint) : void
      {
         var _loc2_:PetInfo = _bagMap.getValue(defaultTime) as PetInfo;
         if(Boolean(_loc2_))
         {
            _loc2_.isDefault = false;
         }
         _loc2_ = _bagMap.getValue(param1) as PetInfo;
         if(Boolean(_loc2_))
         {
            defaultTime = param1;
            _loc2_.isDefault = true;
            dispatchEvent(new PetEvent(PetEvent.SET_DEFAULT,defaultTime));
         }
      }
      
      public static function showCurrent() : void
      {
         showPet(currentShowCatchTime);
      }
      
      public static function showPet(param1:uint) : void
      {
         if(param1 == 0)
         {
            param1 = uint(catchTimes[0]);
         }
         currentShowCatchTime = param1;
         var _loc2_:PetInfo = _bagMap.getValue(param1);
         if(!_loc2_)
         {
            Alarm.show("你还没有精灵");
            return;
         }
         if(showInfo == null)
         {
            if(MainManager.actorInfo.actionType != 0)
            {
               if(PetXMLInfo.isFlyPet(_loc2_.id) || PetXMLInfo.isRidePet(_loc2_.id))
               {
                  Alarm.show("NONO飞行模式开启时，不能召唤骑宠精灵哦！");
                  return;
               }
            }
            showInfo = _loc2_;
            SocketConnection.send(CommandID.PET_SHOW,_loc2_.catchTime,1);
         }
         else if(showInfo.catchTime == param1)
         {
            showInfo = null;
            SocketConnection.send(CommandID.PET_SHOW,_loc2_.catchTime,0);
         }
         else
         {
            if(MainManager.actorInfo.actionType != 0)
            {
               if(PetXMLInfo.isFlyPet(_loc2_.id) || PetXMLInfo.isRidePet(_loc2_.id))
               {
                  Alarm.show("NONO飞行模式开启时，不能召唤骑宠精灵哦！");
                  return;
               }
            }
            showInfo = _loc2_;
            SocketConnection.send(CommandID.PET_SHOW,_loc2_.catchTime,1);
         }
      }
      
      public static function cureAll(param1:Boolean = true) : void
      {
         var isTip:Boolean = param1;
         var isCure:Boolean = false;
         _bagMap.eachValue(function(param1:PetInfo):void
         {
            var _loc2_:PetSkillInfo = null;
            if(param1.hp != param1.maxHp)
            {
               isCure = true;
               return;
            }
            var _loc3_:int = 0;
            while(_loc3_ < param1.skillNum)
            {
               _loc2_ = param1.skillArray[_loc3_] as PetSkillInfo;
               if(_loc2_.pp != SkillXMLInfo.getPP(_loc2_.id))
               {
                  isCure = true;
                  return;
               }
               _loc3_++;
            }
         });
         if(!isCure)
         {
            Alarm.show("你的精灵们不需要恢复体力");
            return;
         }
         SocketConnection.addCmdListener(CommandID.PET_CURE,function(param1:SocketEvent):void
         {
            var e:SocketEvent = param1;
            SocketConnection.removeCmdListener(CommandID.PET_CURE,arguments.callee);
            _bagMap.eachValue(function(param1:PetInfo):void
            {
               var _loc2_:PetSkillInfo = null;
               param1.hp = param1.maxHp;
               var _loc3_:int = 0;
               while(_loc3_ < param1.skillNum)
               {
                  _loc2_ = param1.skillArray[_loc3_] as PetSkillInfo;
                  _loc2_.pp = SkillXMLInfo.getPP(_loc2_.id);
                  _loc3_++;
               }
            });
            dispatchEvent(new PetEvent(PetEvent.CURE_COMPLETE,0));
            if(isTip)
            {
               Alarm.show("已花费50个赛尔豆使你的精灵重新充满活力了!");
            }
            MainManager.actorInfo.coins -= 50;
         });
         SocketConnection.send(CommandID.PET_CURE);
      }
      
      public static function cure(param1:uint) : void
      {
         var i:int = 0;
         var catchTime:uint = param1;
         var info:PetSkillInfo = null;
         var isCure:Boolean = false;
         var petInfo:PetInfo = _bagMap.getValue(catchTime);
         if(!petInfo)
         {
            Alarm.show("没有找到精灵");
            return;
         }
         if(petInfo.hp != petInfo.maxHp)
         {
            isCure = true;
         }
         i = 0;
         while(i < petInfo.skillNum)
         {
            info = petInfo.skillArray[i] as PetSkillInfo;
            if(info.pp != SkillXMLInfo.getPP(info.id))
            {
               isCure = true;
               break;
            }
            i++;
         }
         if(!isCure)
         {
            Alarm.show("你的精灵不需要恢复体力");
            return;
         }
         SocketConnection.addCmdListener(CommandID.PET_ONE_CURE,function(param1:SocketEvent):void
         {
            var _loc3_:int = 0;
            var _loc4_:PetSkillInfo = null;
            SocketConnection.removeCmdListener(CommandID.PET_ONE_CURE,arguments.callee);
            var _loc5_:ByteArray = param1.data as ByteArray;
            var _loc6_:uint = _loc5_.readUnsignedInt();
            var _loc7_:PetInfo = _bagMap.getValue(_loc6_);
            if(Boolean(_loc7_))
            {
               _loc7_.hp = _loc7_.maxHp;
               _loc3_ = 0;
               while(_loc3_ < _loc7_.skillNum)
               {
                  _loc4_ = _loc7_.skillArray[_loc3_] as PetSkillInfo;
                  _loc4_.pp = SkillXMLInfo.getPP(_loc4_.id);
                  _loc3_++;
               }
            }
            dispatchEvent(new PetEvent(PetEvent.CURE_ONE_COMPLETE,_loc6_));
            Alarm.show("你的精灵已经重新充满活力了");
            if(MainManager.actorInfo.superNono != 1)
            {
               MainManager.actorInfo.coins -= 20;
            }
         });
         SocketConnection.send(CommandID.PET_ONE_CURE,catchTime);
      }
      
      public static function get storageLength() : int
      {
         return _storageMap.length - _bagMap.length;
      }
      
      public static function get allLength() : int
      {
         return _storageMap.length;
      }
      
      public static function getAll() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:PetListInfo = null;
         var _loc3_:Array = _storageMap.getValues();
         if(_bagMap.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _bagMap.length)
            {
               if(containsStorageForCapTime((_bagMap.getValues()[_loc1_] as PetInfo).catchTime) == false)
               {
                  _loc2_ = new PetListInfo();
                  _loc2_.catchTime = (_bagMap.getValues()[_loc1_] as PetInfo).catchTime;
                  _loc2_.id = (_bagMap.getValues()[_loc1_] as PetInfo).id;
                  _loc3_.push(_loc2_);
               }
               _loc1_++;
            }
         }
         return _loc3_;
      }
      
      public static function getCanExePetList() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:PetListInfo = null;
         var _loc4_:Array = _storageMap.getValues();
         if(Boolean(_loc4_))
         {
            _loc1_ = 0;
            while(_loc1_ < _loc4_.length)
            {
               if((_loc4_[_loc1_] as PetListInfo).course != 0)
               {
                  _loc4_.splice(_loc1_,1);
                  _loc1_--;
               }
               _loc1_++;
            }
         }
         if(_bagMap.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _bagMap.length)
            {
               if(containsStorageForCapTime((_bagMap.getValues()[_loc2_] as PetInfo).catchTime) == false)
               {
                  _loc3_ = new PetListInfo();
                  _loc3_.catchTime = (_bagMap.getValues()[_loc2_] as PetInfo).catchTime;
                  _loc3_.id = (_bagMap.getValues()[_loc2_] as PetInfo).id;
                  _loc4_.push(_loc3_);
               }
               _loc2_++;
            }
         }
         return _loc4_;
      }
      
      public static function getStorage() : Array
      {
         var arr:Array = _storageMap.getValues();
         return arr.filter(function(param1:PetListInfo, param2:int, param3:Array):Boolean
         {
            if(!_bagMap.containsKey(param1.catchTime))
            {
               return true;
            }
            return false;
         });
      }
      
      public static function getStorageList() : void
      {
         if(_isgetdata)
         {
            dispatchEvent(new PetEvent(PetEvent.STORAGE_LIST,0));
            return;
         }
         SocketConnection.addCmdListener(CommandID.GET_PET_LIST,function(param1:SocketEvent):void
         {
            var _loc3_:PetListInfo = null;
            SocketConnection.removeCmdListener(CommandID.GET_PET_LIST,arguments.callee);
            var _loc4_:ByteArray = param1.data as ByteArray;
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:int = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = new PetListInfo(_loc4_);
               _storageMap.add(_loc3_.catchTime,_loc3_);
               _loc6_++;
            }
            if(MainManager.actorInfo.hasNono)
            {
               if(Boolean(NonoManager.info))
               {
                  if(Boolean(NonoManager.info.func[3]))
                  {
                     getExePetList();
                  }
                  else
                  {
                     _isgetdata = true;
                     dispatchEvent(new PetEvent(PetEvent.STORAGE_LIST,0));
                  }
               }
               else
               {
                  _isgetdata = true;
                  dispatchEvent(new PetEvent(PetEvent.STORAGE_LIST,0));
               }
            }
            else
            {
               _isgetdata = true;
               dispatchEvent(new PetEvent(PetEvent.STORAGE_LIST,0));
            }
         });
         SocketConnection.send(CommandID.GET_PET_LIST);
      }
      
      private static function getExePetList() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_EXE_LIST,onGetListSucHandler);
         SocketConnection.send(CommandID.NONO_EXE_LIST);
      }
      
      private static function onGetListSucHandler(param1:SocketEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ExeingPetInfo = null;
         var _loc4_:PetListInfo = null;
         SocketConnection.removeCmdListener(CommandID.NONO_EXE_LIST,onGetListSucHandler);
         var _loc5_:ByteArray = param1.data as ByteArray;
         var _loc6_:uint = _loc5_.readUnsignedInt();
         if(_loc6_ > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc6_)
            {
               _loc3_ = new ExeingPetInfo(_loc5_);
               _exePetListMap.add(_loc3_._capTm,_loc3_);
               _loc4_ = new PetListInfo();
               _loc4_.id = _loc3_._petId;
               _loc4_.catchTime = _loc3_._capTm;
               _loc4_.course = _loc3_._course;
               _storageMap.add(_loc3_._capTm,_loc4_);
               if(containsBagForCapTime(_loc3_._capTm))
               {
                  _bagMap.remove(_loc3_._capTm);
               }
               _loc2_++;
            }
         }
         _isgetdata = true;
         dispatchEvent(new PetEvent(PetEvent.STORAGE_LIST,0));
      }
      
      public static function get exePetListMap() : HashMap
      {
         return _exePetListMap;
      }
      
      public static function getBagMap() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:PetListInfo = null;
         if(Boolean(_bagMap))
         {
            if(_bagMap.getValues().length <= 0)
            {
               return [];
            }
            _loc1_ = new Array();
            _loc2_ = 0;
            while(_loc2_ < _bagMap.getValues().length)
            {
               _loc3_ = new PetListInfo();
               _loc3_.catchTime = (_bagMap.getValues()[_loc2_] as PetInfo).catchTime;
               _loc3_.id = (_bagMap.getValues()[_loc2_] as PetInfo).id;
               _loc3_.level = (_bagMap.getValues()[_loc2_] as PetInfo).level;
               _loc1_.push(_loc3_);
               _loc2_++;
            }
            return _loc1_;
         }
         return [];
      }
      
      public static function startExePet(param1:uint, param2:uint) : void
      {
         var capTime:uint = param1;
         var type:uint = param2;
         SocketConnection.addCmdListener(CommandID.NONO_START_EXE,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.NONO_START_EXE,arguments.callee);
            var _loc3_:ByteArray = param1.data as ByteArray;
            var _loc4_:Number = _loc3_.readUnsignedInt();
            var _loc5_:Number = _loc3_.readUnsignedInt();
            var _loc6_:Number = _loc3_.readUnsignedInt();
            var _loc7_:Number = _loc3_.readUnsignedInt();
            var _loc8_:ExeingPetInfo = new ExeingPetInfo();
            _loc8_._flag = 0;
            _loc8_._capTm = _loc4_;
            _loc8_._petId = _loc5_;
            _loc8_._remainDay = _loc7_ * 24;
            _loc8_._course = _loc7_;
            _exePetListMap.add(_loc8_._capTm,_loc8_);
            var _loc9_:PetListInfo = new PetListInfo();
            _loc9_.id = _loc8_._petId;
            _loc9_.catchTime = _loc8_._capTm;
            _loc9_.course = _loc8_._course;
            _storageMap.add(_loc8_._capTm,_loc9_);
            if(containsBagForCapTime(_loc8_._capTm))
            {
               _bagMap.remove(_loc8_._capTm);
            }
            dispatchEvent(new PetEvent(PetEvent.START_EXE_PET,0));
         });
         SocketConnection.send(CommandID.NONO_START_EXE,capTime,type);
      }
      
      public static function stopExePet(param1:uint, param2:uint) : void
      {
         var id:uint = param1;
         var cap:uint = param2;
         SocketConnection.addCmdListener(CommandID.NONO_END_EXE,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.NONO_END_EXE,arguments.callee);
            var _loc3_:ByteArray = param1.data as ByteArray;
            var _loc4_:uint = _loc3_.readUnsignedInt();
            if(_loc4_ == 0)
            {
               Alarm.show("训练完成，你的精灵已经回到仓库中！");
            }
            else
            {
               Alarm.show("训练完成，你的精灵获得了 " + TextFormatUtil.getRedTxt(_loc4_.toString()) + " 经验！");
            }
            _exePetListMap.remove(cap);
            var _loc5_:PetListInfo = new PetListInfo();
            _loc5_.id = id;
            _loc5_.catchTime = cap;
            _loc5_.course = 0;
            _storageMap.add(_loc5_.catchTime,_loc5_);
            if(containsBagForCapTime(_loc5_.catchTime))
            {
               _bagMap.remove(_loc5_.catchTime);
            }
            dispatchEvent(new PetEvent(PetEvent.STOP_EXE_PET,0));
         });
         SocketConnection.send(CommandID.NONO_END_EXE,cap);
      }
      
      public static function set curEndPetInfo(param1:PetInfo) : void
      {
         _curEndPetInfo = param1;
      }
      
      public static function get curEndPetInfo() : PetInfo
      {
         return _curEndPetInfo;
      }
      
      public static function getRoweiPetList() : void
      {
         roweiPetMap.clear();
         SocketConnection.addCmdListener(CommandID.PET_ROWEI_LIST,onRoweiListHandler);
         SocketConnection.send(CommandID.PET_ROWEI_LIST);
      }
      
      private static function onRoweiListHandler(param1:SocketEvent) : void
      {
         var _loc2_:PetListInfo = null;
         SocketConnection.removeCmdListener(CommandID.PET_ROWEI_LIST,onRoweiListHandler);
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_ = new PetListInfo(_loc3_);
            roweiPetMap.add(_loc2_.catchTime,_loc2_);
            _loc5_++;
         }
         dispatchEvent(new PetEvent(PetEvent.GET_ROWEI_PET_LIST,0));
      }
      
      public static function get roweiPetLength() : uint
      {
         return roweiPetMap.length;
      }
      
      public static function getRoweiTypeList(param1:uint) : Array
      {
         var t:uint = param1;
         var arr:Array = roweiPetMap.getValues();
         return arr.filter(function(param1:PetListInfo, param2:int, param3:Array):Boolean
         {
            if(PetXMLInfo.getType(param1.id) == t.toString())
            {
               return true;
            }
            return false;
         });
      }
      
      public static function roweiPet(param1:uint, param2:uint) : void
      {
         curRoweiPetInfo = new PetListInfo();
         curRoweiPetInfo.id = param1;
         curRoweiPetInfo.catchTime = param2;
         SocketConnection.addCmdListener(CommandID.PET_ROWEI,onRoweiPetSuccessHandler);
         SocketConnection.send(CommandID.PET_ROWEI,param1,param2);
      }
      
      public static function onRoweiPetSuccessHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_ROWEI,onRoweiPetSuccessHandler);
         _storageMap.remove(curRoweiPetInfo.catchTime);
         roweiPetMap.add(curRoweiPetInfo.catchTime,curRoweiPetInfo);
         dispatchEvent(new PetEvent(PetEvent.ROWEI_PET,curRoweiPetInfo.catchTime));
      }
      
      public static function retrievePet(param1:uint, param2:uint) : void
      {
         curRetrievePetInfo = new PetListInfo();
         curRetrievePetInfo.id = param1;
         curRetrievePetInfo.catchTime = param2;
         SocketConnection.addCmdListener(CommandID.PET_RETRIEVE,onRetrievePetSuccessHandler);
         SocketConnection.send(CommandID.PET_RETRIEVE,param2);
      }
      
      private static function onRetrievePetSuccessHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_RETRIEVE,onRetrievePetSuccessHandler);
         _storageMap.add(curRetrievePetInfo.catchTime,curRetrievePetInfo);
         roweiPetMap.remove(curRetrievePetInfo.catchTime);
         dispatchEvent(new PetEvent(PetEvent.RETRIEVE_PET,curRetrievePetInfo.catchTime));
      }
      
      public static function storageUpDate(param1:uint, param2:Function) : void
      {
         var catchTime:uint = param1;
         var event:Function = param2;
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,arguments.callee);
            event(param1.data as PetInfo);
         });
         SocketConnection.send(CommandID.GET_PET_INFO,catchTime);
      }
      
      public static function getStorageTypeList(param1:uint) : Array
      {
         var t:uint = param1;
         var arr:Array = getStorage();
         return arr.filter(function(param1:PetListInfo, param2:int, param3:Array):Boolean
         {
            if(PetXMLInfo.getType(param1.id) == t.toString())
            {
               return true;
            }
            return false;
         });
      }
      
      public static function addStorage(param1:uint, param2:uint) : void
      {
         var _loc3_:PetListInfo = new PetListInfo();
         _loc3_.id = param1;
         _loc3_.catchTime = param2;
         _storageMap.add(param2,_loc3_);
         dispatchEvent(new PetEvent(PetEvent.STORAGE_ADDED,param2));
      }
      
      public static function removeStorage(param1:uint) : PetListInfo
      {
         var _loc2_:PetListInfo = _storageMap.remove(param1);
         if(Boolean(_loc2_))
         {
            dispatchEvent(new PetEvent(PetEvent.STORAGE_REMOVED,param1));
            return _loc2_;
         }
         return null;
      }
      
      public static function containsStorageForID(param1:uint) : Boolean
      {
         var id:uint = param1;
         var arr:Array = _storageMap.getValues();
         return arr.some(function(param1:PetListInfo, param2:int, param3:Array):Boolean
         {
            if(id == param1.id)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function containsStorageForCapTime(param1:uint) : Boolean
      {
         var cap:uint = param1;
         var arr:Array = _storageMap.getValues();
         return arr.some(function(param1:PetListInfo, param2:int, param3:Array):Boolean
         {
            if(cap == param1.catchTime)
            {
               return true;
            }
            return false;
         });
      }
      
      public static function getCanStudySkill(param1:uint, param2:Function = null) : void
      {
         _handler = param2;
         SocketConnection.addCmdListener(CommandID.GET_PET_SKILL,onGetSuccessHandler);
         SocketConnection.send(CommandID.GET_PET_SKILL,param1);
      }
      
      private static function onGetSuccessHandler(param1:SocketEvent) : void
      {
         var _loc6_:uint = 0;
         SocketConnection.removeCmdListener(CommandID.GET_PET_SKILL,onGetSuccessHandler);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc6_ = _loc2_.readUnsignedInt();
            if(_loc6_ != 0)
            {
               _loc4_.push(_loc6_);
            }
            _loc5_++;
         }
         if(_handler != null)
         {
            _handler(_loc4_);
         }
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

