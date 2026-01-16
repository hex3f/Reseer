package org.taomee.ds
{
   public interface ITree
   {
      
      function get depth() : int;
      
      function set data(param1:*) : void;
      
      function get numChildren() : int;
      
      function get length() : int;
      
      function get numSiblings() : int;
      
      function get isLeaf() : Boolean;
      
      function get data() : *;
      
      function remove() : void;
      
      function get isRoot() : Boolean;
      
      function clear() : void;
   }
}

