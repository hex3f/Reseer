package com.robot.app.im.ui
{
   import com.robot.app.im.ui.tab.IIMTab;
   import com.robot.app.im.ui.tab.TabBlack;
   import com.robot.app.im.ui.tab.TabFriend;
   import com.robot.app.im.ui.tab.TabOnline;
   import com.robot.app.popup.AddFriendPanel;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.uic.UIPanel;
   import com.robot.core.uic.UIScrollBar;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.taomee.ds.HashMap;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class IMPanel extends UIPanel
   {
      
      private static const LIST_LENGTH:int = 8;
      
      private var _titleMc:MovieClip;
      
      private var _txt:TextField;
      
      private var _addBtn:SimpleButton;
      
      private var _delBtn:SimpleButton;
      
      private var _allowBtn:SimpleButton;
      
      private var _tabFriend:MovieClip;
      
      private var _tabBlack:MovieClip;
      
      private var _tabNewly:MovieClip;
      
      private var _tabOnline:MovieClip;
      
      private var _tabList:HashMap;
      
      private var _currentTab:IIMTab;
      
      private var _listCon:Sprite;
      
      private var _listData:Array;
      
      private var _scrollBar:UIScrollBar;
      
      public function IMPanel()
      {
         var _loc1_:IMListItem = null;
         this._listData = [];
         super(UIManager.getSprite("IMMC"));
         this._titleMc = _mainUI["titleMc"];
         this._txt = _mainUI["txt"];
         this._addBtn = _mainUI["addBtn"];
         this._delBtn = _mainUI["delBtn"];
         this._allowBtn = _mainUI["allowBtn"];
         var _loc2_:Sprite = _mainUI["tabPanel"];
         this._tabFriend = _loc2_["tabFriend"];
         this._tabOnline = _loc2_["tabOnline"];
         this._tabBlack = _loc2_["tabBlack"];
         this._titleMc.mouseEnabled = false;
         this._txt.mouseEnabled = false;
         this._allowBtn.visible = false;
         this._scrollBar = new UIScrollBar(_mainUI["barBall"],_mainUI["barBg"],LIST_LENGTH,_mainUI["upBtn"],_mainUI["downBtn"]);
         this._scrollBar.wheelObject = this;
         this._listCon = new Sprite();
         this._listCon.x = 35;
         this._listCon.y = 105;
         _mainUI.addChild(this._listCon);
         var _loc3_:int = 0;
         while(_loc3_ < LIST_LENGTH)
         {
            _loc1_ = new IMListItem();
            _loc1_.y = (_loc1_.height + 4) * _loc3_;
            this._listCon.addChild(_loc1_);
            _loc3_++;
         }
         this._tabList = new HashMap();
         this._tabList.add(this._tabFriend,new TabFriend(1,this._tabFriend,this._listCon,this.refreshItem));
         this._tabList.add(this._tabOnline,new TabOnline(3,this._tabOnline,this._listCon,this.refreshItem));
         this._tabList.add(this._tabBlack,new TabBlack(4,this._tabBlack,this._listCon,this.refreshItem));
         this._currentTab = this._tabList.getValue(this._tabFriend);
         this._titleMc.gotoAndStop(this._currentTab.index);
      }
      
      public function show() : void
      {
         _show();
         LevelManager.appLevel.addChild(this);
         DisplayUtil.align(this,null,AlignType.MIDDLE_RIGHT,new Point(-10,0));
         this._currentTab.show();
      }
      
      override public function hide() : void
      {
         super.hide();
         this._currentTab.hide();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._titleMc = null;
         this._txt = null;
         this._addBtn = null;
         this._delBtn = null;
         this._listCon = null;
         this._listData = null;
         this._tabList = null;
         this._currentTab = null;
         this._scrollBar.destroy();
         this._scrollBar = null;
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         this._addBtn.addEventListener(MouseEvent.CLICK,this.onAddFriend);
         this._delBtn.addEventListener(MouseEvent.CLICK,this.onDelFriend);
         this._scrollBar.addEventListener(MouseEvent.MOUSE_MOVE,this.onScrollMove);
         this._tabFriend.addEventListener(MouseEvent.CLICK,this.onTabClick);
         this._tabBlack.addEventListener(MouseEvent.CLICK,this.onTabClick);
         this._tabOnline.addEventListener(MouseEvent.CLICK,this.onTabClick);
         ToolTipManager.add(this._addBtn,"寻找好友");
         ToolTipManager.add(this._delBtn,"禁加好友");
         ToolTipManager.add(this._tabFriend,"我的好友");
         ToolTipManager.add(this._tabBlack,"黑名单");
         ToolTipManager.add(this._tabOnline,"在线列表");
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         this._addBtn.removeEventListener(MouseEvent.CLICK,this.onAddFriend);
         this._delBtn.removeEventListener(MouseEvent.CLICK,this.onDelFriend);
         this._scrollBar.removeEventListener(MouseEvent.MOUSE_MOVE,this.onScrollMove);
         this._tabFriend.removeEventListener(MouseEvent.CLICK,this.onTabClick);
         this._tabBlack.removeEventListener(MouseEvent.CLICK,this.onTabClick);
         this._tabOnline.removeEventListener(MouseEvent.CLICK,this.onTabClick);
         ToolTipManager.remove(this._addBtn);
         ToolTipManager.remove(this._delBtn);
         ToolTipManager.remove(this._tabFriend);
         ToolTipManager.remove(this._tabBlack);
         ToolTipManager.remove(this._tabOnline);
      }
      
      private function refreshItem(param1:Array, param2:int) : void
      {
         var _loc3_:IMListItem = null;
         var _loc4_:UserInfo = null;
         var _loc5_:IMListItem = null;
         var _loc6_:int = 0;
         while(_loc6_ < LIST_LENGTH)
         {
            _loc3_ = this._listCon.getChildAt(_loc6_) as IMListItem;
            _loc3_.mouseChildren = false;
            _loc3_.mouseEnabled = false;
            _loc3_.clear();
            _loc6_++;
         }
         var _loc7_:int = int(param1.length);
         this._listData = param1;
         this._scrollBar.totalLength = _loc7_;
         this._txt.text = "(" + _loc7_.toString() + "/" + param2.toString() + ")";
         var _loc8_:int = Math.min(LIST_LENGTH,_loc7_);
         var _loc9_:int = 0;
         while(_loc9_ < _loc8_)
         {
            _loc4_ = this._listData[_loc9_ + this._scrollBar.index] as UserInfo;
            _loc5_ = this._listCon.getChildAt(_loc9_) as IMListItem;
            _loc5_.info = _loc4_;
            _loc5_.mouseChildren = true;
            _loc5_.mouseEnabled = true;
            _loc9_++;
         }
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         this._currentTab.hide();
         this._currentTab = this._tabList.getValue(param1.currentTarget);
         this._currentTab.show();
         this._titleMc.gotoAndStop(this._currentTab.index);
      }
      
      private function onScrollMove(param1:MouseEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:IMListItem = null;
         var _loc4_:int = 0;
         while(_loc4_ < LIST_LENGTH)
         {
            _loc2_ = this._listData[_loc4_ + this._scrollBar.index] as UserInfo;
            _loc3_ = this._listCon.getChildAt(_loc4_) as IMListItem;
            _loc3_.clear();
            _loc3_.info = _loc2_;
            _loc4_++;
         }
      }
      
      private function onAddFriend(param1:MouseEvent) : void
      {
         AddFriendPanel.show();
      }
      
      private function onDelFriend(param1:MouseEvent) : void
      {
      }
   }
}

