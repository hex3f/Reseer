package com.robot.app.bag
{
   import com.robot.app.action.ActorActionManager;
   import com.robot.app.team.TeamController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.SuitXMLInfo;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.PeopleActionEvent;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.team.SimpleTeamInfo;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.skeleton.ClothPreview;
   import com.robot.core.teamInstallation.TeamLogo;
   import com.robot.core.ui.itemTip.ItemInfoTip;
   import com.robot.core.utils.ItemType;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.effect.ColorFilter;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.DepthManager;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.ArrayUtil;
   import org.taomee.utils.DisplayUtil;
   
   public class BagPanel extends Sprite
   {
      
      public static const PREV_PAGE:String = "prevPage";
      
      public static const NEXT_PAGE:String = "nextPage";
      
      public static const SHOW_CLOTH:String = "showCloth";
      
      public static const SHOW_COLLECTION:String = "showCollection";
      
      public static const SHOW_NONO:String = "showNoNo";
      
      public static const SHOW_SOULBEAD:String = "showSoulBead";
      
      public static var suitID:uint = 0;
      
      public static var currTab:uint = BagTabType.CLOTH;
      
      private var UI_PATH:String = "resource/module/bag/bagUI.swf";
      
      private var bagMC:MovieClip;
      
      private var closeBtn:SimpleButton;
      
      private var _dragBtn:SimpleButton;
      
      private var clothBtn:MovieClip;
      
      private var collectionBtn:MovieClip;
      
      private var nonoBtn:MovieClip;
      
      private var _typeBtn:MovieClip;
      
      private var _typeTxt:TextField;
      
      private var _typeJian:MovieClip;
      
      private var soulBeadBtn:MovieClip;
      
      private var _typePanel:BagTypePanel;
      
      public var clothPrev:BagClothPreview;
      
      private var _clickItemID:uint;
      
      private var app:ApplicationDomain;
      
      private var _listCon:Sprite;
      
      public var bChangeClothes:Boolean;
      
      private var _showMc:Sprite;
      
      private var instuctorLogo:MovieClip;
      
      private var logo:Sprite;
      
      private var logoCloth:TeamLogo;
      
      private var clothLight:MovieClip;
      
      private var qqMC:Sprite;
      
      private var changeNick:ChangeNickName;
      
      private var maskMc:Sprite;
      
      private var _arrowMc:MovieClip;
      
      public function BagPanel()
      {
         super();
         this.logo = new Sprite();
         this.logo.x = 27;
         this.logo.y = 95;
         this.logo.filters = [new GlowFilter(3355443,1,3,3,2)];
         this.logo.buttonMode = true;
         ToolTipManager.add(this.logo,"进入战队要塞");
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         this.bChangeClothes = true;
         LevelManager.appLevel.addChild(this);
         if(!this.bagMC)
         {
            _loc1_ = new MCLoader(this.UI_PATH,LevelManager.appLevel,1,"正在打开储存箱");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.onLoadBagUI);
            _loc1_.doLoad();
         }
         else
         {
            this.bagMC["nonoMc"].visible = false;
            this.init();
         }
      }
      
      public function hide() : void
      {
         DisplayUtil.removeAllChild(this.qqMC);
         currTab = BagTabType.CLOTH;
         this.changeNick.destory();
         this.changeNick = null;
         var _loc1_:String = MainManager.actorClothStr;
         var _loc2_:Array = this.clothPrev.getClothArray();
         var _loc3_:String = this.clothPrev.getClothStr();
         if(_loc3_ != _loc1_ && !ActorActionManager.isTransforming)
         {
            MainManager.actorModel.changeCloth(_loc2_);
            MainManager.actorInfo.clothes = _loc2_;
            EventManager.dispatchEvent(new Event(PeopleActionEvent.CLOTH_CHANGE));
         }
         if(Boolean(this._typePanel))
         {
            if(DisplayUtil.hasParent(this._typePanel))
            {
               this.onTypePanelHide();
            }
         }
         DisplayUtil.removeForParent(this,false);
         SocketConnection.removeCmdListener(CommandID.GOLD_ONLINE_CHECK_REMAIN,this.onGetGold);
      }
      
      public function showItem(param1:Array) : void
      {
         var _loc2_:SingleItemInfo = null;
         var _loc3_:BagListItem = null;
         var _loc4_:Boolean = false;
         this.clearItemPanel();
         var _loc5_:int = int(param1.length);
         var _loc6_:int = 0;
         for(; _loc6_ < _loc5_; _loc6_++)
         {
            _loc2_ = param1[_loc6_];
            _loc3_ = this._listCon.getChildAt(_loc6_) as BagListItem;
            if(BagShowType.currType == BagShowType.SUIT)
            {
               if(!ItemManager.containsCloth(_loc2_.itemID))
               {
                  _loc3_.setInfo(_loc2_);
                  continue;
               }
            }
            _loc4_ = false;
            if(BagShowType.currType == BagShowType.SUIT)
            {
               _loc4_ = Boolean(ArrayUtil.arrayContainsValue(this.clothPrev.getClothArray(),_loc2_.itemID));
            }
            _loc3_.setInfo(_loc2_,_loc4_);
            if(!_loc4_)
            {
               if(_loc2_.leftTime != 0)
               {
                  if(_loc2_.type == ItemType.CLOTH)
                  {
                     _loc3_.buttonMode = true;
                     _loc3_.addEventListener(MouseEvent.CLICK,this.onChangeCloth);
                  }
               }
            }
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.onShowItemInfo);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onHideItemInfo);
         }
      }
      
      private function vipTabGrayscale() : Boolean
      {
         if(!MainManager.actorInfo.vip)
         {
            if(Boolean(this.nonoBtn))
            {
               this.nonoBtn.mouseEnabled = false;
               this.nonoBtn.filters = [ColorFilter.setGrayscale()];
               return true;
            }
         }
         return false;
      }
      
      private function init() : void
      {
         var _loc1_:* = 0;
         this.bagMC.addChild(this.logo);
         DisplayUtil.removeAllChild(this.logo);
         if(TasksManager.getTaskStatus(201) == TasksManager.COMPLETE)
         {
            this.bagMC.addChild(this.instuctorLogo);
            (this.instuctorLogo as MovieClip).gotoAndStop(1);
            if(MainManager.actorInfo.graduationCount >= 5)
            {
               _loc1_ = uint(uint(MainManager.actorInfo.graduationCount / 5) + 1);
               if(_loc1_ >= 5)
               {
                  (this.instuctorLogo as MovieClip).gotoAndStop(6);
               }
               else
               {
                  (this.instuctorLogo as MovieClip).gotoAndStop(_loc1_);
               }
            }
         }
         if(MainManager.actorInfo.teamInfo.id != 0)
         {
            this.getTeamLogo();
         }
         if(Boolean(MainManager.actorInfo.vip))
         {
            this.bagMC["nonoMc"].visible = true;
            ToolTipManager.add(this.bagMC["nonoMc"],MainManager.actorInfo.vipLevel + "级超能NoNo");
            this.bagMC["nonoMc"]["vipStageMC"].gotoAndStop(MainManager.actorInfo.vipLevel);
         }
         this.goToCloth();
         this.clothPrev.changeColor(MainManager.actorInfo.color);
         this.clothPrev.showCloths(MainManager.actorInfo.clothes);
         this.clothPrev.showDoodle(MainManager.actorInfo.texture);
         this.clothBtn.addEventListener(MouseEvent.CLICK,this.showColth);
         this.clothBtn.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this.clothBtn.addEventListener(MouseEvent.ROLL_OUT,this.onUp);
         this.collectionBtn.addEventListener(MouseEvent.CLICK,this.showPetThings);
         this.collectionBtn.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this.collectionBtn.addEventListener(MouseEvent.ROLL_OUT,this.onUp);
         this.nonoBtn.addEventListener(MouseEvent.CLICK,this.onShowNoNo);
         this.nonoBtn.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this.nonoBtn.addEventListener(MouseEvent.ROLL_OUT,this.onUp);
         this.soulBeadBtn.addEventListener(MouseEvent.CLICK,this.onShowSoulBead);
         this.soulBeadBtn.addEventListener(MouseEvent.ROLL_OVER,this.onSBOver);
         this.soulBeadBtn.addEventListener(MouseEvent.ROLL_OUT,this.onSBUp);
         dispatchEvent(new Event(Event.COMPLETE));
         this.changeNick = new ChangeNickName();
         this.changeNick.init(this.bagMC);
         this.bagMC["miId_txt"].text = "(" + MainManager.actorInfo.userID + ")";
         this.bagMC["money_txt"].text = MainManager.actorInfo.coins;
         ToolTipManager.add(this.bagMC["goldMC"],"赛尔金豆");
         ToolTipManager.add(this.bagMC["coinMC"],"赛尔豆");
         if(Boolean(this.logoCloth) && Boolean(MainManager.actorInfo.teamInfo.isShow))
         {
            addChild(this.logoCloth);
         }
         this.vipTabGrayscale();
         this.getGoldNum();
         this.showClothLight();
         EventManager.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function showClothLight() : void
      {
         DisplayUtil.removeForParent(this.clothLight);
         var _loc1_:uint = uint(MainManager.actorInfo.clothMaxLevel);
         if(_loc1_ > 1)
         {
            ResourceManager.getResource(ClientConfig.getClothLightUrl(_loc1_),this.onLoadLight);
            ResourceManager.getResource(ClientConfig.getClothCircleUrl(_loc1_),this.onLoadQQ);
         }
      }
      
      private function onLoadLight(param1:DisplayObject) : void
      {
         this.clothLight = param1 as MovieClip;
         this.clothLight.scaleX = this.clothLight.scaleY = 3;
         var _loc2_:Rectangle = this._showMc.getRect(this._showMc);
         this.clothLight.x = _loc2_.width / 2 + _loc2_.x;
         this.clothLight.y = _loc2_.height + _loc2_.y;
         this._showMc.addChild(this.clothLight);
      }
      
      private function onLoadQQ(param1:DisplayObject) : void
      {
         DisplayUtil.removeAllChild(this.qqMC);
         this.qqMC.addChild(param1);
      }
      
      private function getGoldNum() : void
      {
         SocketConnection.addCmdListener(CommandID.GOLD_ONLINE_CHECK_REMAIN,this.onGetGold);
         SocketConnection.send(CommandID.GOLD_ONLINE_CHECK_REMAIN);
      }
      
      private function onGetGold(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GOLD_ONLINE_CHECK_REMAIN,this.onGetGold);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:Number = _loc2_.readUnsignedInt() / 100;
         var _loc4_:uint = _loc2_.readUnsignedInt();
         this.bagMC["gold_txt"].text = _loc3_.toString();
         MainManager.actorInfo.coins = _loc4_;
         this.bagMC["money_txt"].text = MainManager.actorInfo.coins;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         (param1.target as MovieClip).gotoAndStop(2);
      }
      
      private function onUp(param1:MouseEvent) : void
      {
         if((param1.target as MovieClip).currentFrame != 1)
         {
            (param1.target as MovieClip).gotoAndStop(3);
         }
      }
      
      private function onSBOver(param1:MouseEvent) : void
      {
         (param1.target as MovieClip).gotoAndStop(2);
      }
      
      private function onSBUp(param1:MouseEvent) : void
      {
         if((param1.target as MovieClip).currentFrame != 1)
         {
            (param1.target as MovieClip).gotoAndStop(3);
         }
      }
      
      private function showColth(param1:MouseEvent) : void
      {
         this.goToCloth();
         dispatchEvent(new Event(SHOW_CLOTH));
      }
      
      public function goToCloth() : void
      {
         currTab = BagTabType.CLOTH;
         BagShowType.currType = BagShowType.ALL;
         this._typeJian.scaleY = 1;
         this._typeTxt.text = BagShowType.typeNameList[BagShowType.currType];
         this._typeBtn.visible = true;
         this._typeTxt.visible = true;
         this._typeJian.visible = true;
         this.clothBtn.gotoAndStop(1);
         this.clothBtn.mouseEnabled = false;
         this.clothBtn.mouseChildren = false;
         DepthManager.bringToTop(this.clothBtn);
         this.collectionBtn.mouseEnabled = true;
         this.collectionBtn.mouseChildren = true;
         this.collectionBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.collectionBtn);
         this.nonoBtn.mouseEnabled = true;
         this.nonoBtn.mouseChildren = true;
         this.nonoBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.nonoBtn);
         this.soulBeadBtn.mouseEnabled = true;
         this.soulBeadBtn.mouseChildren = true;
         this.soulBeadBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.soulBeadBtn);
      }
      
      private function showPetThings(param1:MouseEvent) : void
      {
         currTab = BagTabType.COLLECTION;
         BagShowType.currType = BagShowType.ALL;
         BagShowType.currSuitID = 0;
         this._typeBtn.visible = false;
         this._typeTxt.visible = false;
         this._typeJian.visible = false;
         this.onTypePanelHide();
         this.collectionBtn.gotoAndStop(1);
         this.collectionBtn.mouseEnabled = false;
         this.collectionBtn.mouseChildren = false;
         DepthManager.bringToTop(this.collectionBtn);
         this.clothBtn.mouseEnabled = true;
         this.clothBtn.mouseChildren = true;
         this.clothBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.clothBtn);
         this.nonoBtn.mouseEnabled = true;
         this.nonoBtn.mouseChildren = true;
         this.nonoBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.nonoBtn);
         this.soulBeadBtn.mouseEnabled = true;
         this.soulBeadBtn.mouseChildren = true;
         this.soulBeadBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.soulBeadBtn);
         dispatchEvent(new Event(SHOW_COLLECTION));
      }
      
      private function onShowNoNo(param1:MouseEvent) : void
      {
         if(this.vipTabGrayscale())
         {
            return;
         }
         currTab = BagTabType.NONO;
         BagShowType.currType = BagShowType.ALL;
         this._typeJian.scaleY = 1;
         this._typeTxt.text = BagShowType.typeNameList[BagShowType.currType];
         this._typeBtn.visible = true;
         this._typeTxt.visible = true;
         this._typeJian.visible = true;
         this.nonoBtn.mouseEnabled = false;
         this.nonoBtn.mouseChildren = false;
         this.nonoBtn.gotoAndStop(1);
         DepthManager.bringToTop(this.nonoBtn);
         this.collectionBtn.gotoAndStop(3);
         this.collectionBtn.mouseEnabled = true;
         this.collectionBtn.mouseChildren = true;
         DepthManager.bringToBottom(this.collectionBtn);
         this.clothBtn.mouseEnabled = true;
         this.clothBtn.mouseChildren = true;
         this.clothBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.clothBtn);
         this.soulBeadBtn.mouseEnabled = true;
         this.soulBeadBtn.mouseChildren = true;
         this.soulBeadBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.soulBeadBtn);
         dispatchEvent(new Event(SHOW_NONO));
      }
      
      private function onShowSoulBead(param1:MouseEvent) : void
      {
         currTab = BagTabType.SOULBEAD;
         BagShowType.currType = BagShowType.ALL;
         this._typeJian.scaleY = 1;
         this._typeTxt.text = BagShowType.typeNameList[BagShowType.currType];
         this._typeBtn.visible = false;
         this._typeTxt.visible = false;
         this._typeJian.visible = false;
         this.soulBeadBtn.mouseEnabled = false;
         this.soulBeadBtn.mouseChildren = false;
         this.soulBeadBtn.gotoAndStop(1);
         DepthManager.bringToTop(this.soulBeadBtn);
         this.nonoBtn.mouseEnabled = true;
         this.nonoBtn.mouseChildren = true;
         this.nonoBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.nonoBtn);
         this.collectionBtn.gotoAndStop(3);
         this.collectionBtn.mouseEnabled = true;
         this.collectionBtn.mouseChildren = true;
         DepthManager.bringToBottom(this.collectionBtn);
         this.clothBtn.mouseEnabled = true;
         this.clothBtn.mouseChildren = true;
         this.clothBtn.gotoAndStop(3);
         DepthManager.bringToBottom(this.clothBtn);
         dispatchEvent(new Event(SHOW_SOULBEAD));
      }
      
      private function onTypeClick(param1:MouseEvent) : void
      {
         if(this._typePanel == null)
         {
            this._typePanel = new BagTypePanel(this.app);
            this._typePanel.addEventListener(BagTypeEvent.SELECT,this.onTypeSelect);
            this._typePanel.x = 350;
         }
         if(DisplayUtil.hasParent(this._typePanel))
         {
            this.onTypePanelHide();
         }
         else
         {
            addChild(this._typePanel);
            this._typePanel.setSelect(BagShowType.currType);
            this._typeJian.scaleY = -1;
         }
      }
      
      private function onTypeSelect(param1:BagTypeEvent) : void
      {
         this.onTypePanelHide();
         BagShowType.currType = param1.showType;
         BagShowType.currSuitID = param1.suitID;
         this._typePanel.setSelect(BagShowType.currType);
         this._typeTxt.text = BagShowType.typeNameList[BagShowType.currType];
         dispatchEvent(new BagTypeEvent(BagTypeEvent.SELECT,param1.showType,param1.suitID));
      }
      
      private function onTypePanelHide() : void
      {
         if(Boolean(this._typePanel))
         {
            DisplayUtil.removeForParent(this._typePanel,false);
            this._typeJian.scaleY = 1;
         }
      }
      
      private function prevHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(PREV_PAGE));
      }
      
      private function nextHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(NEXT_PAGE));
      }
      
      private function onLoadBagUI(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this.bagMC = new (this.app.getDefinition("BagPanel") as Class)() as MovieClip;
         this.bagMC["nonoMc"].visible = false;
         addChild(this.bagMC);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         this.instuctorLogo = UIManager.getMovieClip("Teacher_Icon");
         this.instuctorLogo.x = 37;
         this.instuctorLogo.y = 275;
         this._listCon = new Sprite();
         this._listCon.y = 20;
         this._listCon.x = 300;
         this.bagMC.addChild(this._listCon);
         this.closeBtn = this.bagMC["closeBtn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         this.createItemPanel();
         this._dragBtn = this.bagMC["dragBtn"];
         this._dragBtn.useHandCursor = false;
         this._dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
         this.clothBtn = this.bagMC["clothBtn"];
         this.collectionBtn = this.bagMC["collectionBtn"];
         this.nonoBtn = this.bagMC["nonoBtn"];
         ToolTipManager.add(this.clothBtn,"装备部件");
         ToolTipManager.add(this.collectionBtn,"收藏物品");
         ToolTipManager.add(this.nonoBtn,"超能NoNo");
         this.soulBeadBtn = this.bagMC["soulBeadBtn"];
         ToolTipManager.add(this.soulBeadBtn,"精灵元神珠");
         var _loc2_:SimpleButton = this.bagMC["prev_btn"];
         var _loc3_:SimpleButton = this.bagMC["next_btn"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.prevHandler);
         _loc3_.addEventListener(MouseEvent.CLICK,this.nextHandler);
         this._typeBtn = this.bagMC["typeBtn"];
         this._typeTxt = this.bagMC["typeTxt"];
         this._typeJian = this.bagMC["typeJian"];
         this._typeTxt.mouseEnabled = false;
         this._typeJian.mouseEnabled = false;
         this._typeBtn.addEventListener(MouseEvent.CLICK,this.onTypeClick);
         this._showMc = UIManager.getSprite("ComposeMC");
         this._showMc.scaleX = this._showMc.scaleY = 0.9;
         this._showMc.x = 78;
         this._showMc.y = 122;
         this.bagMC.addChild(this._showMc);
         this.clothPrev = new BagClothPreview(this._showMc,null,ClothPreview.MODEL_SHOW);
         this.qqMC = new Sprite();
         this.qqMC.scaleX = 3.2;
         this.qqMC.scaleY = 1.6;
         var _loc4_:Rectangle = this._showMc.getRect(this._showMc);
         this.qqMC.x = _loc4_.width / 2 + _loc4_.x;
         this.qqMC.y = _loc4_.height + _loc4_.y;
         this._showMc.addChildAt(this.qqMC,0);
         this.init();
      }
      
      private function createItemPanel() : void
      {
         var _loc1_:BagListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < 12)
         {
            _loc1_ = new BagListItem(new (this.app.getDefinition("itemPanel") as Class)() as Sprite);
            _loc1_.x = (_loc1_.width + 10) * int(_loc2_ % 3);
            _loc1_.y = (_loc1_.height + 10) * int(_loc2_ / 3);
            this._listCon.addChild(_loc1_);
            _loc2_++;
         }
      }
      
      private function clearItemPanel() : void
      {
         var _loc1_:BagListItem = null;
         var _loc2_:int = this._listCon.numChildren;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = this._listCon.getChildAt(_loc3_) as BagListItem;
            _loc1_.clear();
            _loc1_.removeEventListener(MouseEvent.CLICK,this.onChangeCloth);
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.onShowItemInfo);
            _loc1_.removeEventListener(MouseEvent.ROLL_OUT,this.onHideItemInfo);
            _loc1_.buttonMode = false;
            _loc3_++;
         }
      }
      
      private function onShowItemInfo(param1:MouseEvent) : void
      {
         var _loc2_:BagListItem = param1.currentTarget as BagListItem;
         if(_loc2_.info == null)
         {
            return;
         }
         this._clickItemID = _loc2_.info.itemID;
         ItemInfoTip.show(_loc2_.info);
      }
      
      private function onHideItemInfo(param1:MouseEvent) : void
      {
         ItemInfoTip.hide();
      }
      
      private function onChangeCloth(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         var arr:Array = null;
         var array:Array = null;
         var i:uint = 0;
         var item:BagListItem = event.currentTarget as BagListItem;
         if(item.info == null)
         {
            return;
         }
         ItemInfoTip.hide();
         this._clickItemID = item.info.itemID;
         if(BagShowType.currType == BagShowType.SUIT)
         {
            arr = SuitXMLInfo.getCloths(BagShowType.currSuitID).filter(function(param1:uint, param2:int, param3:Array):Boolean
            {
               if(ItemManager.containsCloth(param1))
               {
                  if(ItemManager.getClothInfo(param1).leftTime == 0)
                  {
                     return false;
                  }
                  return true;
               }
               return false;
            });
            array = [];
            for each(i in arr)
            {
               array.push(new PeopleItemInfo(i));
            }
            this.clothPrev.showCloths(array);
         }
         else
         {
            this.clothPrev.showCloth(this._clickItemID,item.info.itemLevel);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         this.hide();
         this.openEvent();
         dispatchEvent(new Event(Event.CLOSE));
         EventManager.dispatchEvent(new Event(Event.CLOSE));
      }
      
      public function get clickItemID() : uint
      {
         return this._clickItemID;
      }
      
      public function setPageNum(param1:uint, param2:uint) : void
      {
         this.bagMC["page_txt"].text = param1 + "/" + param2;
      }
      
      private function onDragDown(param1:MouseEvent) : void
      {
         if(Boolean(parent))
         {
            parent.addChild(this);
         }
         startDrag();
      }
      
      private function onDragUp(param1:MouseEvent) : void
      {
         stopDrag();
      }
      
      private function getTeamLogo() : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_GET_INFO,this.onGetInfo);
         SocketConnection.send(CommandID.TEAM_GET_INFO,MainManager.actorInfo.teamInfo.id);
      }
      
      private function onGetInfo(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TEAM_GET_INFO,this.onGetInfo);
         var _loc2_:SimpleTeamInfo = param1.data as SimpleTeamInfo;
         var _loc3_:TeamLogo = new TeamLogo();
         _loc3_.info = _loc2_;
         _loc3_.scaleX = _loc3_.scaleY = 0.8;
         this.logo.addChild(_loc3_);
         _loc3_.addEventListener(MouseEvent.CLICK,this.showTeamInfo);
         if(Boolean(this.logoCloth))
         {
            DisplayUtil.removeForParent(this.logoCloth);
            this.logoCloth.removeEventListener(MouseEvent.CLICK,this.removeLogo);
         }
         this.logoCloth = _loc3_.clone();
         this.logoCloth.addEventListener(MouseEvent.CLICK,this.removeLogo);
         this.checkLogoCloth();
      }
      
      private function removeLogo(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.TEAM_SHOW_LOGO,this.onTeamShowLogo);
         SocketConnection.send(CommandID.TEAM_SHOW_LOGO,0);
      }
      
      private function onTeamShowLogo(param1:SocketEvent) : void
      {
         DisplayUtil.removeForParent(this.logoCloth);
      }
      
      private function showTeamInfo(param1:MouseEvent) : void
      {
         var _loc2_:TeamLogo = param1.currentTarget as TeamLogo;
         TeamController.show(_loc2_.teamID);
      }
      
      private function checkLogoCloth() : void
      {
         if(MainManager.actorInfo.teamInfo.isShow)
         {
            if(Boolean(this.logoCloth))
            {
               this.logoCloth.x = (270 - this.logoCloth.width) / 2;
               this.logoCloth.y = 80;
               addChild(this.logoCloth);
            }
         }
         else
         {
            DisplayUtil.removeForParent(this.logoCloth);
         }
      }
      
      public function closeEvent() : void
      {
         if(Boolean(this._typeBtn))
         {
            this._typeBtn.mouseChildren = false;
            this._typeBtn.mouseEnabled = false;
         }
         this.maskMc = new Sprite();
         this.maskMc.graphics.beginFill(0,1);
         this.maskMc.graphics.lineStyle(1,0);
         this.maskMc.graphics.drawRect(0,0,580,380);
         this.maskMc.graphics.endFill();
         this.maskMc.alpha = 0;
         this.bagMC.addChildAt(this.maskMc,this.bagMC.getChildIndex(this._showMc) + 1);
         this.bagMC.addChild(this.closeBtn);
         this._arrowMc = TaskIconManager.getIcon("Arrows_MC") as MovieClip;
         this.addChild(this._arrowMc);
         this._arrowMc.x = 220;
         this._arrowMc.y = 43;
         MovieClip(this._arrowMc["mc"]).rotation = -180;
         MovieClip(this._arrowMc["mc"]).play();
      }
      
      public function openEvent() : void
      {
         if(Boolean(this._typeBtn))
         {
            this._typeBtn.mouseChildren = true;
            this._typeBtn.mouseEnabled = true;
         }
         if(Boolean(this.maskMc))
         {
            this.maskMc.graphics.clear();
            DisplayUtil.removeForParent(this.maskMc);
            this.maskMc = null;
         }
         if(Boolean(this._arrowMc))
         {
            DisplayUtil.removeForParent(this._arrowMc);
            this._arrowMc = null;
         }
      }
   }
}

