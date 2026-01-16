package com.robot.app.im.ui.tab
{
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.BasePeoleModel;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class TabOnline implements IIMTab
   {
      
      private var _index:int;
      
      private var _fun:Function;
      
      private var _ui:MovieClip;
      
      private var _con:Sprite;
      
      public function TabOnline(param1:int, param2:MovieClip, param3:Sprite, param4:Function)
      {
         super();
         this._index = param1;
         this._ui = param2;
         this._ui.gotoAndStop(1);
         this._con = param3;
         this._fun = param4;
      }
      
      public function show() : void
      {
         var _loc1_:BasePeoleModel = null;
         this._ui.mouseEnabled = false;
         if(Boolean(this._ui.parent))
         {
            this._ui.parent.addChild(this._ui);
            this._ui.gotoAndStop(2);
         }
         var _loc2_:Array = [];
         var _loc3_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc3_)
         {
            _loc2_.push(_loc1_.info);
         }
         _loc2_.sortOn("vip",Array.DESCENDING | Array.NUMERIC);
         this._fun(_loc2_,300);
      }
      
      public function hide() : void
      {
         this._ui.mouseEnabled = true;
         if(Boolean(this._ui.parent))
         {
            this._ui.parent.addChildAt(this._ui,0);
            this._ui.gotoAndStop(1);
         }
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
   }
}

