package com.robot.core.display.tree
{
   public class StatefulNode extends Node
   {
      
      private var _open:Boolean = false;
      
      private var _closed:Boolean;
      
      private var _isNewAndUN:Boolean = false;
      
      private var _isClick:Boolean = false;
      
      public function StatefulNode(param1:String, param2:INode, param3:* = null)
      {
         super(param1,param2,param3);
      }
      
      public function hasOpenChilds() : Boolean
      {
         var _loc1_:StatefulNode = null;
         for each(_loc1_ in children)
         {
            if(_loc1_.isOpen())
            {
               return true;
            }
         }
         return false;
      }
      
      public function hasIsNewAndUNChilds() : Boolean
      {
         var _loc1_:StatefulNode = null;
         for each(_loc1_ in children)
         {
            if(_loc1_.isNewAndUN)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setClosed(param1:Boolean) : void
      {
         this._closed = param1;
      }
      
      public function isClosed() : Boolean
      {
         return this._closed;
      }
      
      public function setOpen(param1:Boolean) : void
      {
         this._open = param1;
      }
      
      public function isOpen() : Boolean
      {
         return this._open;
      }
      
      public function set isNewAndUN(param1:Boolean) : void
      {
         this._isNewAndUN = param1;
      }
      
      public function get isNewAndUN() : Boolean
      {
         return this._isNewAndUN;
      }
      
      public function set isClick(param1:Boolean) : void
      {
         this._isClick = param1;
      }
      
      public function get isClick() : Boolean
      {
         return this._isClick;
      }
   }
}

