package visualize
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.uic.UIScrollBar;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.DisplayUtil;
   import others.CommendSvrInfo;
   import others.RangeSvrInfo;
   import others.ServerInfo;
   import tip.TipPanel;
   
   public class ServerList extends Sprite
   {
      
      private static const LIST_LENGTH:int = 10;
      
      private var csl:CommendSvrInfo;
      
      private var serPanel:severPanelxx;
      
      private var _scrollBar:UIScrollBar;
      
      private var _listCon:Sprite;
      
      private var resourceAry:Array;
      
      private var _maxOnlineID:uint;
      
      private var curSp:Sprite;
      
      private var allSvrBtn:SimpleButton;
      
      private var curSvrList:Array;
      
      private var curPageIndex:uint;
      
      private var totalPages:uint;
      
      public function ServerList(param1:CommendSvrInfo)
      {
         super();
         this.curPageIndex = 1;
         this.resourceAry = new Array();
         this.csl = param1;
         this.curSvrList = this.csl.SvrList;
         this.serPanel = new severPanelxx();
         this.serPanel.addEventListener(Event.ADDED_TO_STAGE,this.addToStage);
         addChild(this.serPanel);
         this.serPanel.sevrTxt.addEventListener(FocusEvent.FOCUS_IN,this.clearSvrTxt);
         this.serPanel.sevrTxt.addEventListener(KeyboardEvent.KEY_UP,this.onEnterByKey);
         this.serPanel.selBtn.addEventListener(MouseEvent.CLICK,this.enterGame);
         this._maxOnlineID = this.csl.MaxOnlineID;
         this.totalPages = Math.ceil(this._maxOnlineID / 100);
         this.serPanel.pageTxt.text = this.curPageIndex.toString() + "/" + this.totalPages.toString();
         this.allSvrBtn = this.serPanel.allSvrBtn;
         this.allSvrBtn.addEventListener(MouseEvent.CLICK,this.showAllSvr);
         this.serPanel.preBtn.visible = false;
         this.serPanel.nextBtn.visible = false;
         this.serPanel.pageTxt.visible = false;
         this.serPanel.preBtn.addEventListener(MouseEvent.CLICK,this.preServer);
         this.serPanel.nextBtn.addEventListener(MouseEvent.CLICK,this.nextServer);
      }
      
      private function addToStage(param1:Event) : void
      {
         this._scrollBar = new UIScrollBar(this.serPanel.barBall,this.serPanel.barBg,LIST_LENGTH,this.serPanel.upBtn,this.serPanel.downBtn);
         this._scrollBar.wheelObject = this.serPanel;
         this.initItems();
         this._scrollBar.addEventListener(MouseEvent.MOUSE_MOVE,this.onScrollMove);
      }
      
      private function preServer(param1:MouseEvent) : void
      {
         if(this.curPageIndex == 1)
         {
            return;
         }
         this.getRangeServer((this.curPageIndex - 2) * 100 + 1,(this.curPageIndex - 1) * 100);
         --this.curPageIndex;
         this.serPanel.pageTxt.text = this.curPageIndex.toString() + "/" + this.totalPages.toString();
      }
      
      private function nextServer(param1:MouseEvent) : void
      {
         if(this.curPageIndex == this.totalPages)
         {
            return;
         }
         this.getRangeServer(this.curPageIndex * 100 + 1,(this.curPageIndex + 1) * 100);
         ++this.curPageIndex;
         this.serPanel.pageTxt.text = this.curPageIndex.toString() + "/" + this.totalPages.toString();
      }
      
      private function initItems() : void
      {
         var _loc1_:SeverListItem = null;
         var _loc2_:ServerInfo = null;
         if(Boolean(this._listCon))
         {
            DisplayUtil.removeAllChild(this._listCon);
            this._listCon = null;
         }
         this._listCon = new Sprite();
         this._listCon.x = 50;
         this._listCon.y = 120;
         this.serPanel.addChild(this._listCon);
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         for(; _loc4_ < LIST_LENGTH; _loc4_++)
         {
            if(_loc4_ < this.curSvrList.length)
            {
               _loc2_ = this.curSvrList[_loc4_];
               if(_loc2_.OnlineID == 0)
               {
                  _loc3_ = true;
                  continue;
               }
            }
            _loc1_ = new SeverListItem();
            if(_loc3_)
            {
               _loc1_.x = (_loc1_.width + 40) * ((_loc4_ - 1) % 2);
               _loc1_.y = (_loc1_.height + 10) * Math.floor((_loc4_ - 1) / 2);
            }
            else
            {
               _loc1_.x = (_loc1_.width + 40) * (_loc4_ % 2);
               _loc1_.y = (_loc1_.height + 10) * Math.floor(_loc4_ / 2);
            }
            this._listCon.addChild(_loc1_);
            if(_loc4_ < this.curSvrList.length)
            {
               _loc1_.info = _loc2_;
               _loc1_.refresh();
               _loc1_.buttonMode = true;
               _loc1_.mouseChildren = false;
               _loc1_.addEventListener(MouseEvent.CLICK,this.onEnter);
            }
            else
            {
               _loc1_.visible = false;
            }
         }
         this._scrollBar.totalLength = this.curSvrList.length;
         trace(Math.ceil(this.curSvrList.length / 2) + "*********");
      }
      
      private function onScrollMove(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:SeverListItem = null;
         trace(this._scrollBar.index);
         var _loc4_:int = 0;
         while(_loc4_ < LIST_LENGTH)
         {
            _loc2_ = _loc4_ + this._scrollBar.index;
            _loc3_ = this._listCon.getChildAt(_loc4_) as SeverListItem;
            _loc3_.info = this.curSvrList[_loc2_];
            _loc3_.refresh();
            _loc4_++;
         }
      }
      
      private function clearSvrTxt(param1:FocusEvent) : void
      {
         this.serPanel.sevrTxt.text = "";
      }
      
      private function onEnter(param1:MouseEvent) : void
      {
         var _loc2_:SeverListItem = null;
         var _loc3_:SeverListItem = param1.target as SeverListItem;
         var _loc4_:ServerInfo = _loc3_.info;
         soundmanger.getInstance().stopBgMusic();
         MainManager.serverID = _loc4_.OnlineID;
         trace(_loc4_.OnlineID + "号");
         Login.dispatch(_loc4_.IP.toString(),_loc4_.Port.toString(),this.csl.friendData);
         for each(_loc2_ in this.resourceAry)
         {
            _loc2_.parent.removeChild(_loc2_);
            _loc2_.removeEventListener(MouseEvent.CLICK,this.onEnter);
            _loc2_ = null;
         }
         this.resourceAry = null;
         this.serPanel.sevrTxt.removeEventListener(FocusEvent.FOCUS_IN,this.clearSvrTxt);
         this.serPanel.sevrTxt.removeEventListener(KeyboardEvent.KEY_UP,this.onEnterByKey);
         this.serPanel.selBtn.removeEventListener(MouseEvent.CLICK,this.enterGame);
         this.serPanel.parent.removeChild(this.serPanel);
         this.serPanel = null;
      }
      
      private function onEnterByKey(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.enterGameBySearch();
         }
      }
      
      private function enterGameBySearch() : void
      {
         var _loc1_:ServerInfo = null;
         var _loc2_:Boolean = false;
         var _loc3_:uint = uint(this.serPanel.sevrTxt.text);
         if(this.serPanel.sevrTxt.text == "0")
         {
            TipPanel.createTipPanel("你输入的服务器不存在！");
            return;
         }
         if(this.serPanel.sevrTxt.text == "" || this.serPanel.sevrTxt.text == "请输入服务器名或编号")
         {
            TipPanel.createTipPanel("请输入服务器名或编号！");
            return;
         }
         for each(_loc1_ in this.curSvrList)
         {
            MainManager.serverID = _loc3_;
            if(_loc3_ == _loc1_.OnlineID)
            {
               if(_loc1_.UserCnt >= ClientConfig.maxPeople)
               {
                  TipPanel.createTipPanel("你选择的服务器已经满员");
                  this.serPanel.sevrTxt.text = "";
                  return;
               }
               Login.dispatch(_loc1_.IP.toString(),_loc1_.Port.toString(),this.csl.friendData);
               _loc2_ = true;
               break;
            }
         }
         if(!_loc2_)
         {
            SocketConnection.addCmdListener(CommandID.RANGE_ONLINE,this.onSingleList);
            SocketConnection.send(CommandID.RANGE_ONLINE,_loc3_,_loc3_,0);
         }
      }
      
      private function onSingleList(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.RANGE_ONLINE,this.onSingleList);
         var _loc2_:RangeSvrInfo = param1.data as RangeSvrInfo;
         if(_loc2_.SvrList.length == 0)
         {
            TipPanel.createTipPanel("你输入的服务器不存在！");
            return;
         }
         var _loc3_:ServerInfo = _loc2_.SvrList[0] as ServerInfo;
         Login.dispatch(_loc3_.IP.toString(),_loc3_.Port.toString(),this.csl.friendData);
      }
      
      private function enterGame(param1:MouseEvent) : void
      {
         this.enterGameBySearch();
      }
      
      private function showAllSvr(param1:MouseEvent) : void
      {
         this.serPanel.preBtn.visible = true;
         this.serPanel.nextBtn.visible = true;
         this.serPanel.pageTxt.visible = true;
         this.getRangeServer();
         this.curPageIndex = 1;
         this.serPanel.pageTxt.text = this.curPageIndex.toString() + "/" + this.totalPages.toString();
      }
      
      private function getRangeServer(param1:int = 1, param2:int = 100) : void
      {
         SocketConnection.addCmdListener(CommandID.RANGE_ONLINE,this.onListServer);
         SocketConnection.send(CommandID.RANGE_ONLINE,param1,param2,0);
      }
      
      private function onListServer(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.RANGE_ONLINE,this.onListServer);
         var _loc2_:RangeSvrInfo = param1.data as RangeSvrInfo;
         this.curSvrList = _loc2_.SvrList;
         this.initItems();
      }
      
      private function exit(param1:MouseEvent) : void
      {
         this.visible = false;
      }
   }
}

