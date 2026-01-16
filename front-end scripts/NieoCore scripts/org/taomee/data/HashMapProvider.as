package org.taomee.data
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import org.taomee.ds.HashMap;
   
   [Event(name="preDataChange",type="fl.events.DataChangeEvent")]
   [Event(name="dataChange",type="fl.events.DataChangeEvent")]
   public class HashMapProvider extends EventDispatcher
   {
      
      private var _data:HashMap = new HashMap();
      
      public var autoUpdate:Boolean = true;
      
      public function HashMapProvider()
      {
         super();
      }
      
      public function containsKey(param1:*) : Boolean
      {
         return this._data.containsKey(param1);
      }
      
      protected function dispatchPreChangeEvent(param1:String, param2:Array) : void
      {
         if(!this.autoUpdate)
         {
            return;
         }
         if(hasEventListener(DataChangeEvent.PRE_DATA_CHANGE))
         {
            dispatchEvent(new DataChangeEvent(DataChangeEvent.PRE_DATA_CHANGE,param1,param2));
         }
      }
      
      public function dispatchSelectMulti(param1:IEventDispatcher, param2:Array, param3:Array) : void
      {
         var _loc4_:int = int(param2.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            this._data.add(param2[_loc5_],param3[_loc5_]);
            _loc5_++;
         }
         param1.dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE,DataChangeType.SELECT,param3.concat()));
      }
      
      public function remove(param1:*) : *
      {
         var _loc2_:* = this._data.remove(param1);
         if(_loc2_)
         {
            this.dispatchChangeEvent(DataChangeType.REMOVE,[_loc2_]);
            return _loc2_;
         }
         return null;
      }
      
      public function addMulti(param1:Array, param2:Array) : Array
      {
         var _loc3_:* = undefined;
         var _loc4_:Array = [];
         var _loc5_:int = int(param1.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = this._data.add(param1[_loc6_],param2[_loc6_]);
            if(_loc3_)
            {
               _loc4_.push(_loc3_);
            }
            _loc6_++;
         }
         this.dispatchChangeEvent(DataChangeType.ADD,param2.concat());
         return _loc4_;
      }
      
      public function removeForValue(param1:*) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:* = this._data.getKey(param1);
         if(_loc3_)
         {
            _loc2_ = this._data.remove(_loc3_);
            if(_loc2_)
            {
               this.dispatchChangeEvent(DataChangeType.REMOVE,[_loc2_]);
               return _loc2_;
            }
         }
         return null;
      }
      
      public function removeMulti(param1:Array) : Array
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         var _loc4_:Array = [];
         for each(_loc2_ in param1)
         {
            _loc3_ = this._data.remove(_loc2_);
            if(_loc3_)
            {
               _loc4_.push(_loc3_);
            }
         }
         if(_loc4_.length > 0)
         {
            this.dispatchChangeEvent(DataChangeType.REMOVE,_loc4_.concat());
         }
         return _loc4_;
      }
      
      public function dispatchSelect(param1:IEventDispatcher, param2:*, param3:*) : void
      {
         this._data.add(param2,param3);
         param1.dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE,DataChangeType.SELECT,[param3]));
      }
      
      public function getValues() : Array
      {
         return this._data.getValues();
      }
      
      public function containsValue(param1:*) : Boolean
      {
         return this._data.containsValue(param1);
      }
      
      public function refresh() : void
      {
         this.dispatchChangeEvent(DataChangeType.RESET,this._data.getValues());
      }
      
      public function removeMultiForValue(param1:Array) : Array
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc5_:Array = [];
         for each(_loc2_ in param1)
         {
            _loc3_ = this._data.getKey(_loc2_);
            if(_loc3_)
            {
               _loc4_ = this._data.remove(_loc3_);
               if(_loc4_)
               {
                  _loc5_.push(_loc4_);
               }
            }
         }
         if(_loc5_.length > 0)
         {
            this.dispatchChangeEvent(DataChangeType.REMOVE,_loc5_.concat());
         }
         return _loc5_;
      }
      
      public function upDateForKey(param1:*, param2:*) : void
      {
         var _loc3_:* = undefined;
         if(this._data.containsKey(param1))
         {
            _loc3_ = this._data.add(param1,param2);
            if(_loc3_)
            {
               this.dispatchPreChangeEvent(DataChangeType.UPDATE,[_loc3_]);
            }
            this.dispatchChangeEvent(DataChangeType.UPDATE,[param2]);
         }
      }
      
      public function add(param1:*, param2:*) : *
      {
         var _loc3_:* = this._data.add(param1,param2);
         this.dispatchChangeEvent(DataChangeType.ADD,[param2]);
         return _loc3_;
      }
      
      public function get length() : uint
      {
         return this._data.length;
      }
      
      public function getKey(param1:*) : *
      {
         return this._data.getKey(param1);
      }
      
      public function getKeys() : Array
      {
         return this._data.getKeys();
      }
      
      public function upDateForValue(param1:*, param2:*) : void
      {
         var _loc3_:* = this._data.getKey(param1);
         if(_loc3_)
         {
            this._data.add(_loc3_,param2);
            this.dispatchPreChangeEvent(DataChangeType.UPDATE,[param1]);
            this.dispatchChangeEvent(DataChangeType.UPDATE,[param2]);
         }
      }
      
      protected function dispatchChangeEvent(param1:String, param2:Array) : void
      {
         if(!this.autoUpdate)
         {
            return;
         }
         if(hasEventListener(DataChangeEvent.DATA_CHANGE))
         {
            dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE,param1,param2));
         }
      }
      
      public function toHashMap() : HashMap
      {
         return this._data.clone();
      }
      
      public function getValue(param1:*) : *
      {
         return this._data.getValue(param1);
      }
      
      public function removeAll() : void
      {
         var _loc1_:Array = this._data.getValues();
         this._data.clear();
         this.dispatchChangeEvent(DataChangeType.REMOVE_ALL,_loc1_);
      }
   }
}

