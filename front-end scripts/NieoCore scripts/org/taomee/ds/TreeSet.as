package org.taomee.ds
{
   public class TreeSet implements ITree
   {
      
      private var _root:TreeSet;
      
      private var _data:*;
      
      private var _parent:TreeSet;
      
      private var _children:HashSet;
      
      public function TreeSet(param1:* = null, param2:TreeSet = null)
      {
         super();
         this._data = param1;
         this._children = new HashSet();
         this.parent = param2;
      }
      
      public function get depth() : int
      {
         if(!this._parent)
         {
            return 0;
         }
         var _loc1_:TreeSet = this._parent;
         var _loc2_:int = 0;
         while(Boolean(_loc1_))
         {
            _loc2_++;
            _loc1_ = _loc1_.parent;
            if(_loc1_ == this)
            {
               throw new Error("TreeSet Infinite Loop");
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
         this._children.each2(function(param1:TreeSet):void
         {
            param1.parent = _parent;
         });
      }
      
      public function clear() : void
      {
         this._children = new HashSet();
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
      
      public function get root() : TreeSet
      {
         return this._root;
      }
      
      public function set parent(param1:TreeSet) : void
      {
         if(Boolean(this._parent))
         {
            this._parent.children.remove(this);
         }
         if(param1 == this)
         {
            return;
         }
         this._parent = param1;
         if(Boolean(this._parent))
         {
            this._parent.children.add(this);
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
         var _loc1_:TreeSet = this._parent;
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
               throw new Error("TreeSet Infinite Loop");
            }
         }
      }
      
      public function get length() : int
      {
         var _loc1_:int = this.numChildren;
         var _loc2_:TreeSet = this._parent;
         while(Boolean(_loc2_))
         {
            _loc1_ += _loc2_.numChildren;
            _loc2_ = _loc2_.parent;
            if(_loc2_ == this)
            {
               throw new Error("TreeSet Infinite Loop");
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
      
      public function get parent() : TreeSet
      {
         return this._parent;
      }
      
      public function get children() : HashSet
      {
         return this._children;
      }
   }
}

