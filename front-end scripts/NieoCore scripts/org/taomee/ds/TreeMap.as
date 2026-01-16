package org.taomee.ds
{
   public class TreeMap implements ITree
   {
      
      private var _root:TreeMap;
      
      private var _data:*;
      
      private var _parent:TreeMap;
      
      private var _children:HashMap;
      
      private var _key:*;
      
      public function TreeMap(param1:*, param2:* = null, param3:TreeMap = null)
      {
         super();
         this._key = param1;
         this._data = param2;
         this._children = new HashMap();
         this.parent = param3;
      }
      
      public function get depth() : int
      {
         if(this._parent == null)
         {
            return 0;
         }
         var _loc1_:TreeMap = this._parent;
         var _loc2_:int = 0;
         while(Boolean(_loc1_))
         {
            _loc2_++;
            _loc1_ = _loc1_.parent;
            if(_loc1_ == this)
            {
               throw new Error("TreeMap Infinite Loop");
            }
         }
         return _loc2_;
      }
      
      public function remove() : void
      {
         if(this._parent == null)
         {
            return;
         }
         this._children.eachValue(function(param1:TreeMap):void
         {
            param1.parent = _parent;
         });
      }
      
      public function get parent() : TreeMap
      {
         return this._parent;
      }
      
      public function clear() : void
      {
         this._children = new HashMap();
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function get numSiblings() : int
      {
         if(Boolean(this._parent))
         {
            return this._parent.numChildren;
         }
         return 0;
      }
      
      public function get key() : *
      {
         return this._key;
      }
      
      public function get root() : TreeMap
      {
         return this._root;
      }
      
      public function set parent(param1:TreeMap) : void
      {
         if(Boolean(this._parent))
         {
            this._parent.children.remove(this._key);
         }
         if(param1 == this)
         {
            return;
         }
         this._parent = param1;
         if(Boolean(this._parent))
         {
            this._parent.children.add(this._key,this);
         }
         this.setRoot();
      }
      
      private function setRoot() : void
      {
         if(this._parent == null)
         {
            this._root = this;
            return;
         }
         var _loc1_:TreeMap = this._parent;
         while(Boolean(_loc1_))
         {
            if(_loc1_.parent == null)
            {
               this._root = _loc1_;
               return;
            }
            _loc1_ = _loc1_.parent;
            if(_loc1_ == this)
            {
               throw new Error("TreeMap Infinite Loop");
            }
         }
      }
      
      public function get length() : int
      {
         var _loc1_:int = this.numChildren;
         var _loc2_:TreeMap = this._parent;
         while(Boolean(_loc2_))
         {
            _loc1_ += _loc2_.numChildren;
            _loc2_ = _loc2_.parent;
            if(_loc2_ == this)
            {
               throw new Error("TreeMap Infinite Loop");
            }
         }
         return _loc1_;
      }
      
      public function get isLeaf() : Boolean
      {
         return this._children.length == 0;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function get isRoot() : Boolean
      {
         return this._root == this;
      }
      
      public function get numChildren() : int
      {
         return this._children.length;
      }
      
      public function set key(param1:*) : void
      {
         if(Boolean(this._parent))
         {
            this._parent.children.remove(this._key);
            this._parent.children.add(param1,this);
         }
         this._key = param1;
      }
      
      public function get children() : HashMap
      {
         return this._children;
      }
   }
}

