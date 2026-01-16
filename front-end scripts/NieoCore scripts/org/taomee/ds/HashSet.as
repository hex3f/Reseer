package org.taomee.ds
{
   import flash.utils.Dictionary;
   
   public class HashSet implements ICollection
   {
      
      private var _length:int;
      
      private var _weakKeys:Boolean;
      
      private var _content:Dictionary;
      
      public function HashSet(param1:Boolean = false)
      {
         super();
         this._weakKeys = param1;
         this._content = new Dictionary(param1);
         this._length = 0;
      }
      
      public function addAll(param1:Array) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1)
         {
            this.add(_loc2_);
         }
      }
      
      public function add(param1:*) : void
      {
         switch(param1)
         {
            case undefined:
               return;
            case undefined:
               ++this._length;
         }
         this._content[param1] = param1;
      }
      
      public function containsAll(param1:Array) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(this._content[param1[_loc2_]] === undefined)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function isEmpty() : Boolean
      {
         return this._length == 0;
      }
      
      public function remove(param1:*) : Boolean
      {
         if(this._content[param1] !== undefined)
         {
            delete this._content[param1];
            --this._length;
            return true;
         }
         return false;
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function clone() : HashSet
      {
         var _loc1_:* = undefined;
         var _loc2_:HashSet = new HashSet(this._weakKeys);
         for each(_loc1_ in this._content)
         {
            _loc2_.add(_loc1_);
         }
         return _loc2_;
      }
      
      public function each2(param1:Function) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._content)
         {
            param1(_loc2_);
         }
      }
      
      public function clear() : void
      {
         this._content = new Dictionary(this._weakKeys);
         this._length = 0;
      }
      
      public function removeAll(param1:Array) : void
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in param1)
         {
            this.remove(_loc2_);
         }
      }
      
      public function toArray() : Array
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
      
      public function contains(param1:*) : Boolean
      {
         if(this._content[param1] === undefined)
         {
            return false;
         }
         return true;
      }
   }
}

