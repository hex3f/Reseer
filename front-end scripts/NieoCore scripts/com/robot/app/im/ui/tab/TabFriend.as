package com.robot.app.im.ui.tab
{
   import com.robot.app.im.ui.IMListItem;
   import com.robot.core.event.RelationEvent;
   import com.robot.core.manager.RelationManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class TabFriend implements IIMTab
   {
      
      private var _index:int;
      
      private var _fun:Function;
      
      private var _ui:MovieClip;
      
      private var _con:Sprite;
      
      public function TabFriend(param1:int, param2:MovieClip, param3:Sprite, param4:Function)
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
         this._ui.mouseEnabled = false;
         if(Boolean(this._ui.parent))
         {
            this._ui.parent.addChild(this._ui);
            this._ui.gotoAndStop(2);
         }
         RelationManager.addEventListener(RelationEvent.FRIEND_ADD,this.onRelation);
         RelationManager.addEventListener(RelationEvent.FRIEND_REMOVE,this.onRelation);
         RelationManager.addEventListener(RelationEvent.FRIEND_UPDATE_ONLINE,this.onRelation);
         RelationManager.addEventListener(RelationEvent.UPDATE_INFO,this.onRelation);
         RelationManager.setOnLineFriend();
      }
      
      public function hide() : void
      {
         this._ui.mouseEnabled = true;
         if(Boolean(this._ui.parent))
         {
            this._ui.parent.addChildAt(this._ui,0);
            this._ui.gotoAndStop(1);
         }
         RelationManager.removeEventListener(RelationEvent.FRIEND_ADD,this.onRelation);
         RelationManager.removeEventListener(RelationEvent.FRIEND_REMOVE,this.onRelation);
         RelationManager.removeEventListener(RelationEvent.FRIEND_UPDATE_ONLINE,this.onRelation);
         RelationManager.removeEventListener(RelationEvent.UPDATE_INFO,this.onRelation);
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function set index(param1:int) : void
      {
         this._index = param1;
      }
      
      private function onRelation(param1:RelationEvent) : void
      {
         var _loc2_:IMListItem = null;
         switch(param1.type)
         {
            case RelationEvent.FRIEND_ADD:
            case RelationEvent.FRIEND_REMOVE:
            case RelationEvent.FRIEND_UPDATE_ONLINE:
               this._fun(RelationManager.getFriendInfos(),RelationManager.F_MAX);
               break;
            case RelationEvent.UPDATE_INFO:
               if(param1.userID == 0)
               {
                  this._fun(RelationManager.getFriendInfos(),RelationManager.F_MAX);
               }
               else
               {
                  _loc2_ = this._con.getChildByName(param1.userID.toString()) as IMListItem;
                  if(Boolean(_loc2_))
                  {
                     _loc2_.info = RelationManager.getFriendInfo(param1.userID);
                  }
               }
         }
      }
   }
}

