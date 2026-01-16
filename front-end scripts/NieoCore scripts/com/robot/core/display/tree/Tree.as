package com.robot.core.display.tree
{
   import com.robot.core.utils.ArrayUtils;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   
   public class Tree
   {
      
      private var _root:INode;
      
      public function Tree(param1:INode)
      {
         super();
         this._root = param1;
      }
      
      public static function visit(param1:INode, param2:Function) : void
      {
         var _loc3_:INode = null;
         for each(_loc3_ in param1.children)
         {
            param2(_loc3_);
            visit(_loc3_,param2);
         }
      }
      
      public static function clone(param1:INode) : INode
      {
         var _loc2_:INode = new Node(param1.name,null,param1.data);
         cloneHelper(param1,_loc2_);
         return _loc2_;
      }
      
      private static function cloneHelper(param1:INode, param2:INode) : void
      {
         var _loc3_:INode = null;
         for each(_loc3_ in param1.children)
         {
            cloneHelper(_loc3_,param2.addChild(new Node(_loc3_.name,param2,_loc3_.data)));
         }
      }
      
      public static function toXml(param1:Tree, param2:String = "tree", param3:String = "node") : XML
      {
         var _loc4_:XMLDocument = new XMLDocument();
         var _loc5_:XMLNode = _loc4_.createElement(param2);
         _loc4_.appendChild(_loc5_);
         getXml(param1.root,_loc5_,_loc4_,param3);
         return new XML(_loc4_.toString());
      }
      
      private static function getXml(param1:INode, param2:XMLNode, param3:XMLDocument, param4:String) : void
      {
         var _loc5_:INode = null;
         var _loc6_:XMLNode = null;
         for each(_loc5_ in param1.children)
         {
            if(param4 == null)
            {
               param4 = _loc5_.name;
            }
            _loc6_ = param3.createElement(param4);
            if(param4 != _loc5_.name)
            {
               _loc6_.attributes = {"name":_loc5_.name};
            }
            else
            {
               param4 = null;
            }
            param2.appendChild(_loc6_);
            getXml(_loc5_,_loc6_,param3,param4);
         }
      }
      
      public static function fromXml(param1:Tree, param2:XML, param3:Class = null) : Tree
      {
         if(param3 == null)
         {
            param3 = Node;
         }
         var _loc4_:XMLDocument = new XMLDocument();
         _loc4_.parseXML(param2);
         createTree(_loc4_.firstChild,param1.root = new param3("tree",null),param3);
         return param1;
      }
      
      private static function createTree(param1:XMLNode, param2:INode, param3:Class) : void
      {
         var _loc4_:XMLNode = null;
         var _loc5_:INode = null;
         for each(_loc4_ in param1.childNodes)
         {
            if(_loc4_.nodeName != null)
            {
               _loc5_ = new param3(_loc4_.attributes["name"],param2);
               param2.addChild(_loc5_);
               createTree(_loc4_,_loc5_,param3);
            }
         }
      }
      
      public static function getParentNodeChain(param1:INode) : Array
      {
         var _loc2_:Array = new Array();
         getParentNodeChainHelper(param1,_loc2_);
         return _loc2_;
      }
      
      private static function getParentNodeChainHelper(param1:INode, param2:Array) : void
      {
         var _loc3_:INode = param1.parent as INode;
         if(Boolean(_loc3_))
         {
            param2.push(_loc3_);
            getParentNodeChainHelper(_loc3_,param2);
         }
      }
      
      public static function getCommonParent(param1:INode, param2:INode) : INode
      {
         var _loc3_:INode = null;
         var _loc4_:INode = null;
         var _loc5_:Array = getParentNodeChain(param1);
         var _loc6_:Array = getParentNodeChain(param2);
         for each(_loc3_ in _loc5_)
         {
            for each(_loc4_ in _loc6_)
            {
               if(_loc3_ == _loc4_)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public static function getNodesUntilCommonParent(param1:INode, param2:Array) : Array
      {
         var _loc3_:Array = new Array();
         getNodesUntilCommonParentHelper(param1,_loc3_,param2);
         return _loc3_;
      }
      
      private static function getNodesUntilCommonParentHelper(param1:INode, param2:Array, param3:Array) : void
      {
         param2.push(param1);
         var _loc4_:INode = param1.parent as INode;
         if(Boolean(_loc4_) && (!ArrayUtils.contains(param3,_loc4_) && !ArrayUtils.contains(param3,param1)))
         {
            getNodesUntilCommonParentHelper(_loc4_,param2,param3);
         }
      }
      
      public static function getNodeByNameID(param1:String, param2:INode) : INode
      {
         var _loc3_:INode = null;
         var _loc4_:INode = null;
         if(param2.name == param1)
         {
            return param2;
         }
         for each(_loc3_ in param2.children)
         {
            _loc4_ = getNodeByNameID(param1,_loc3_);
            if(_loc4_ != null)
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public static function getAllChildren(param1:INode) : Array
      {
         var _loc2_:Array = new Array();
         getAllChildrenHelper(param1,_loc2_);
         return _loc2_;
      }
      
      private static function getAllChildrenHelper(param1:INode, param2:Array) : void
      {
         var _loc3_:INode = null;
         for each(_loc3_ in param1.children)
         {
            param2.push(_loc3_);
            getAllChildrenHelper(_loc3_,param2);
         }
      }
      
      public function get root() : INode
      {
         return this._root;
      }
      
      public function set root(param1:INode) : void
      {
         this._root = param1;
      }
      
      public function toArray() : Array
      {
         var _loc1_:Array = new Array();
         this.walk(this._root,_loc1_);
         return _loc1_;
      }
      
      private function walk(param1:INode, param2:Array) : void
      {
         var _loc3_:INode = null;
         param2.push(param1);
         for each(_loc3_ in param1.children)
         {
            this.walk(_loc3_,param2);
         }
      }
      
      public function finalize() : void
      {
         this._root.finalize();
      }
   }
}

