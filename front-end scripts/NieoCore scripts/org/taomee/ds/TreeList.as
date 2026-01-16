package org.taomee.ds
{
   public class TreeList implements ITree
   {
      
      private var _root:TreeList;
      
      private var _data:*;
      
      private var _parent:TreeList;
      
      private var _children:Array;
      
      public function TreeList(param1:* = null, param2:TreeList = null)
      {
         super();
         this._data = param1;
         this._children = [];
         this.parent = param2;
      }
      
      public function get depth() : int
      {
         if(this._parent == null)
         {
            return 0;
         }
         var _loc1_:TreeList = this._parent;
         var _loc2_:int = 0;
         while(Boolean(_loc1_))
         {
            _loc2_++;
            _loc1_ = _loc1_.parent;
            if(_loc1_ == this)
            {
               throw new Error("TreeList Infinite Loop");
            }
         }
         return _loc2_;
      }
      
      public function remove() : void
      {
         var _loc1_:TreeList = null;
         if(this._parent == null)
         {
            return;
         }
         for each(_loc1_ in this._children)
         {
            _loc1_.parent = this._parent;
         }
      }
      
      public function clear() : void
      {
         this._children = [];
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
      
      public function get root() : TreeList
      {
         return this._root;
      }
      
      public function set parent(param1:TreeList) : void
      {
         var _loc2_:int = 0;
         if(Boolean(this._parent))
         {
            _loc2_ = int(this._parent.children.indexOf(this));
            if(_loc2_ != -1)
            {
               this._parent.children.splice(_loc2_,1);
            }
         }
         if(param1 == this)
         {
            return;
         }
         this._parent = param1;
         if(Boolean(this._parent))
         {
            this._parent.children.push(this);
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
         var _loc1_:TreeList = this._parent;
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
               throw new Error("TreeList Infinite Loop");
            }
         }
      }
      
      public function get length() : int
      {
         var _loc1_:int = this.numChildren;
         var _loc2_:TreeList = this._parent;
         while(Boolean(_loc2_))
         {
            _loc1_ += _loc2_.numChildren;
            _loc2_ = _loc2_.parent;
            if(_loc2_ == this)
            {
               throw new Error("TreeList Infinite Loop");
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
      
      public function get parent() : TreeList
      {
         return this._parent;
      }
      
      public function get children() : Array
      {
         return this._children;
      }
   }
}

