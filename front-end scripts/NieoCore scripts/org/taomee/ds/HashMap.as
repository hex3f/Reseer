package org.taomee.ds
{
   import flash.utils.Dictionary;
   
   public class HashMap implements ICollection
   {
      
      private var _length:int;
      
      private var _weakKeys:Boolean;
      
      private var _content:Dictionary;
      
      public function HashMap(param1:Boolean = false)
      {
         super();
         this._weakKeys = param1;
         this._length = 0;
         this._content = new Dictionary(param1);
      }
      
      public function containsKey(param1:*) : Boolean
      {
         if(this._content[param1] === undefined)
         {
            return false;
         }
         return true;
      }
      
      public function remove(param1:*) : *
      {
         if(this._content[param1] === undefined)
         {
            return null;
         }
         var _loc2_:* = this._content[param1];
         delete this._content[param1];
         --this._length;
         return _loc2_;
      }
      
      public function some(param1:Function) : Boolean
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._content)
         {
            if(param1(_loc2_,this._content[_loc2_]))
            {
               return true;
            }
         }
         return false;
      }
      
      public function clear() : void
      {
         this._length = 0;
         this._content = new Dictionary(this._weakKeys);
      }
      
      public function each2(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._content)
         {
            param1(_loc2_,this._content[_loc2_]);
         }
      }
      
      public function isEmpty() : Boolean
      {
         return this._length == 0;
      }
      
      public function getValues() : Array
      {
         var _loc1_:* = undefined;
         var _loc2_:Array = new Array(this._length);
         var _loc3_:int = 0;
         for each(_loc1_ in this._content)
         {
            _loc2_[_loc3_] = _loc1_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function containsValue(param1:*) : Boolean
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._content)
         {
            if(_loc2_ === param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clone() : HashMap
      {
         var _loc1_:* = undefined;
         var _loc2_:HashMap = new HashMap(this._weakKeys);
         for(_loc1_ in this._content)
         {
            _loc2_.add(_loc1_,this._content[_loc1_]);
         }
         return _loc2_;
      }
      
      public function eachKey(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._content)
         {
            param1(_loc2_);
         }
      }
      
      public function add(param1:*, param2:*) : *
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
         this._content[param1] = param2;
         return _loc3_;
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function getKey(param1:*) : *
      {
         var _loc2_:* = undefined;
         for(_loc2_ in this._content)
         {
            if(this._content[_loc2_] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getKeys() : Array
      {
         var _loc1_:* = undefined;
         var _loc2_:Array = new Array(this._length);
         var _loc3_:int = 0;
         for(_loc1_ in this._content)
         {
            _loc2_[_loc3_] = _loc1_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function toString() : String
      {
         var _loc1_:int = 0;
         var _loc2_:Array = this.getKeys();
         var _loc3_:Array = this.getValues();
         var _loc4_:int = int(_loc2_.length);
         var _loc5_:String = "HashMap Content:\n";
         _loc1_ = 0;
         while(_loc1_ < _loc4_)
         {
            _loc5_ += _loc2_[_loc1_] + " -> " + _loc3_[_loc1_] + "\n";
            _loc1_++;
         }
         return _loc5_;
      }
      
      public function eachValue(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._content)
         {
            param1(_loc2_);
         }
      }
      
      public function filter(param1:Function) : Array
      {
         var _loc2_:* = undefined;
         var _loc3_:* = undefined;
         var _loc4_:Array = [];
         for(_loc2_ in this._content)
         {
            _loc3_ = this._content[_loc2_];
            if(param1(_loc2_,_loc3_))
            {
               _loc4_.push(_loc3_);
            }
         }
         return _loc4_;
      }
      
      public function getValue(param1:*) : *
      {
         var _loc2_:* = this._content[param1];
         return _loc2_ === undefined ? null : _loc2_;
      }
   }
}

