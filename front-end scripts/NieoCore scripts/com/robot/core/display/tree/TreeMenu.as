package com.robot.core.display.tree
{
   import com.robot.core.manager.TasksManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TreeMenu extends Sprite
   {
      
      private var _tree:Tree;
      
      private var _btnArr:Array;
      
      private var _display:Sprite;
      
      private var _itemname:String = "";
      
      private var _clickBtnY:Number = 0;
      
      public function TreeMenu(param1:Tree)
      {
         super();
         this._tree = param1;
         this._display = new Sprite();
         this.addChild(this._display);
         this.renderTree();
      }
      
      private function renderTree(param1:String = "") : void
      {
         var _loc2_:StatefulNode = null;
         var _loc3_:Boolean = false;
         var _loc4_:MovieClip = null;
         var _loc5_:Btn = null;
         this._btnArr = new Array();
         var _loc6_:Array = this._tree.toArray();
         var _loc7_:* = 0;
         for each(_loc2_ in _loc6_)
         {
            if(_loc2_.isOpen() && _loc2_ != this._tree.root)
            {
               _loc3_ = false;
               if(_loc2_.hasIsNewAndUNChilds() && !_loc2_.isClick)
               {
                  _loc3_ = true;
               }
               _loc4_ = TreeItem.createItem(_loc2_.data,_loc3_);
               _loc5_ = new Btn(_loc2_.name,_loc4_,_loc2_);
               _loc5_.addEventListener(MouseEvent.CLICK,this.onRelease);
               if(_loc2_.layer == 1)
               {
                  _loc5_.display.x = 10;
               }
               _loc5_.display.y = _loc7_;
               this._display.addChild(_loc5_.display);
               _loc7_ = _loc5_.display.y + _loc5_.display.height + 2;
               this._btnArr.push(_loc5_);
            }
            if(_loc2_.name == param1)
            {
               this._clickBtnY = _loc7_;
            }
         }
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      private function onRelease(param1:MouseEvent) : void
      {
         this.select((param1.target as Btn).nameID);
         if(this._itemname == (param1.target as Btn).nameID)
         {
            return;
         }
         this._itemname = (param1.target as Btn).nameID;
         dispatchEvent(new ItemClickEvent(param1.target as Btn,ItemClickEvent.ITEMCLICK));
      }
      
      public function select(param1:String, param2:Array = null, param3:Boolean = true) : void
      {
         var _loc4_:StatefulNode = null;
         var _loc5_:StatefulNode = null;
         var _loc6_:StatefulNode = null;
         var _loc7_:StatefulNode = Tree.getNodeByNameID(param1,this._tree.root) as StatefulNode;
         if(_loc7_ == null)
         {
            return;
         }
         _loc7_.isClick = true;
         for each(_loc4_ in _loc7_.children)
         {
            for each(_loc5_ in _loc4_.children)
            {
               if(_loc5_.data.newOnline == "1")
               {
                  if(TasksManager.getTaskStatus(_loc5_.data.id) == TasksManager.UN_ACCEPT)
                  {
                     _loc5_.isNewAndUN = true;
                  }
               }
            }
         }
         if(!_loc7_.hasOpenChilds())
         {
            for each(_loc6_ in _loc7_.children)
            {
               _loc6_.setOpen(true);
               this.openClosedNodes(_loc6_);
            }
            _loc7_.setOpen(true);
            this.openParents(_loc7_);
         }
         else
         {
            this.closeChildren(_loc7_);
         }
         this.finishTree();
         this.renderTree(_loc7_.name);
         this.markButton(_loc7_.name);
      }
      
      public function finishTree() : void
      {
         this._clickBtnY = 0;
         while(this._display.numChildren > 0)
         {
            this._display.removeChildAt(0);
         }
      }
      
      private function markButton(param1:String) : void
      {
         var _loc2_:Btn = null;
         for each(_loc2_ in this._btnArr)
         {
            if(_loc2_.nameID == param1)
            {
               _loc2_.mark();
            }
            else
            {
               _loc2_.unmark();
            }
         }
      }
      
      private function closeBrotherNodesChildren(param1:StatefulNode, param2:StatefulNode) : void
      {
         if(param1.name != param2.name)
         {
            this.closeChildren(param2);
         }
      }
      
      private function openClosedNodes(param1:StatefulNode) : void
      {
         var _loc2_:StatefulNode = null;
         for each(_loc2_ in param1.children)
         {
            if(_loc2_.isClosed())
            {
               _loc2_.setOpen(true);
               this.openClosedNodes(_loc2_);
            }
         }
      }
      
      private function closeChildren(param1:StatefulNode) : void
      {
         var _loc2_:StatefulNode = null;
         for each(_loc2_ in param1.children)
         {
            if(_loc2_.isOpen())
            {
               _loc2_.setClosed(true);
            }
            else
            {
               _loc2_.setClosed(false);
            }
            _loc2_.setOpen(false);
            this.closeChildren(_loc2_);
         }
      }
      
      private function openParents(param1:StatefulNode) : void
      {
         var _loc2_:StatefulNode = null;
         var _loc3_:StatefulNode = param1.parent as StatefulNode;
         if(Boolean(_loc3_))
         {
            _loc3_.setOpen(true);
            for each(_loc2_ in _loc3_.children)
            {
               _loc2_.setOpen(true);
               this.closeBrotherNodesChildren(param1,_loc2_);
            }
            this.openParents(_loc3_);
         }
         else
         {
            param1.setOpen(true);
         }
      }
      
      public function finalize() : void
      {
         this.finishTree();
         this._tree.finalize();
      }
      
      public function get display() : DisplayObject
      {
         return this._display;
      }
      
      public function getItemCount() : uint
      {
         return this._btnArr.length;
      }
      
      public function getClickBtnY() : Number
      {
         return this._clickBtnY;
      }
   }
}

