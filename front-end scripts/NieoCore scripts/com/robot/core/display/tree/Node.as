package com.robot.core.display.tree
{
   public class Node implements INode
   {
      
      private var _name:String;
      
      private var _children:Array;
      
      private var _data:*;
      
      private var _parent:INode;
      
      public function Node(param1:String, param2:INode, param3:* = null)
      {
         super();
         this._name = param1;
         this._parent = param2;
         this._data = param3;
      }
      
      public function get children() : Array
      {
         if(this._children == null)
         {
            return new Array();
         }
         return this._children;
      }
      
      public function addChild(param1:INode) : INode
      {
         if(this._children == null)
         {
            this._children = new Array();
         }
         this._children.push(param1);
         return param1;
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function set data(param1:*) : void
      {
         this._data = param1;
      }
      
      public function get layer() : uint
      {
         return this.parent != null ? uint(this._parent.layer + 1) : 0;
      }
      
      public function get parent() : INode
      {
         return this._parent;
      }
      
      public function set parent(param1:INode) : void
      {
         this._parent = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function finalize() : void
      {
         var _loc1_:INode = null;
         for each(_loc1_ in this._children)
         {
            _loc1_.finalize();
         }
         this._children = null;
         this._data = null;
         this._parent = null;
      }
      
      public function toString() : String
      {
         var _loc1_:String = this.parent != null ? this._parent.name : null;
         return "Node name " + this.name + " parent id " + _loc1_ + " layer " + this.layer + " data " + this.data;
      }
   }
}

