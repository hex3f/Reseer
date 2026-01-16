package com.robot.core.display.tree
{
   public interface INode
   {
      
      function addChild(param1:INode) : INode;
      
      function get children() : Array;
      
      function get data() : *;
      
      function set data(param1:*) : void;
      
      function get layer() : uint;
      
      function get parent() : INode;
      
      function set parent(param1:INode) : void;
      
      function get name() : String;
      
      function finalize() : void;
   }
}

