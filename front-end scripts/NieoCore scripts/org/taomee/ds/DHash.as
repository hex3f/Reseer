package org.taomee.ds
{
   import flash.utils.Dictionary;
   
   public class DHash implements ICollection
   {
      
      private var _contentKey:Dictionary;
      
      private var _length:int;
      
      private var _contentValue:Dictionary;
      
      private var _weakKeys:Boolean;
      
      public function DHash(param1:Boolean = false)
      {
         super();
         this._weakKeys = param1;
         this._length = 0;
         this._contentKey = new Dictionary(param1);
         this._contentValue = new Dictionary(param1);
      }
      
      public function containsKey(param1:*) : Boolean
      {
         return this._contentKey[param1] !== undefined;
      }
      
      public function isEmpty() : Boolean
      {
         return this._length == 0;
      }
      
      public function clear() : void
      {
         this._length = 0;
         this._contentKey = new Dictionary(this._weakKeys);
         this._contentValue = new Dictionary(this._weakKeys);
      }
      
      public function each2(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._contentKey)
         {
            param1(_loc2_,this._contentKey[_loc2_]);
         }
      }
      
      public function containsValue(param1:*) : Boolean
      {
         return this._contentValue[param1] !== undefined;
      }
      
      public function removeForValue(param1:*) : *
      {
         var _loc2_:* = undefined;
         if(this._contentValue[param1] !== undefined)
         {
            _loc2_ = this._contentValue[param1];
            delete this._contentValue[param1];
            delete this._contentKey[_loc2_];
            --this._length;
            return _loc2_;
         }
         return null;
      }
      
      public function addForKey(param1:*, param2:*) : *
      {
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            throw new ArgumentError("cannot put a value with undefined or null key!");
         }
         switch(param2)
         {
            case undefined:
               return null;
            case undefined:
               ++this._length;
         }
         _loc3_ = this.getValue(param1);
         delete this._contentValue[_loc3_];
         this._contentKey[param1] = param2;
         this._contentValue[param2] = param1;
         return _loc3_;
      }
      
      public function getValues() : Array
      {
         var _loc1_:* = undefined;
         var _loc2_:Array = new Array(this._length);
         var _loc3_:int = 0;
         for each(_loc1_ in this._contentKey)
         {
            _loc2_[_loc3_] = _loc1_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function clone() : DHash
      {
         var _loc1_:* = undefined;
         var _loc2_:DHash = new DHash(this._weakKeys);
         for(_loc1_ in this._contentKey)
         {
            _loc2_.addForKey(_loc1_,this._contentKey[_loc1_]);
         }
         return _loc2_;
      }
      
      public function contains(param1:*) : Boolean
      {
         if(this._contentKey[param1] !== undefined)
         {
            return true;
         }
         if(this._contentValue[param1] !== undefined)
         {
            return true;
         }
         return false;
      }
      
      public function eachKey(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._contentValue)
         {
            param1(_loc2_);
         }
      }
      
      public function addForValue(param1:*, param2:*) : *
      {
         var _loc3_:* = undefined;
         if(param1 == null)
         {
            throw new ArgumentError("cannot put a key with undefined or null value!");
         }
         switch(param2)
         {
            case undefined:
               return null;
            case undefined:
               ++this._length;
         }
         _loc3_ = this.getKey(param1);
         delete this._contentKey[_loc3_];
         this._contentValue[param1] = param2;
         this._contentKey[param2] = param1;
         return _loc3_;
      }
      
      public function getKeys() : Array
      {
         var _loc1_:* = undefined;
         var _loc2_:Array = new Array(this._length);
         var _loc3_:int = 0;
         for each(_loc1_ in this._contentValue)
         {
            _loc2_[_loc3_] = _loc1_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function getKey(param1:*) : *
      {
         var _loc2_:* = this._contentValue[param1];
         return _loc2_ === undefined ? null : _loc2_;
      }
      
      public function eachValue(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._contentKey)
         {
            param1(_loc2_);
         }
      }
      
      public function removeForKey(param1:*) : *
      {
         var _loc2_:* = undefined;
         if(this._contentKey[param1] !== undefined)
         {
            _loc2_ = this._contentKey[param1];
            delete this._contentKey[param1];
            delete this._contentValue[_loc2_];
            --this._length;
            return _loc2_;
         }
         return null;
      }
      
      public function getValue(param1:*) : *
      {
         var _loc2_:* = this._contentKey[param1];
         return _loc2_ === undefined ? null : _loc2_;
      }
   }
}

