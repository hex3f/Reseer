package com.robot.app.bag
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.taomee.events.DynamicEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class BagTypePanel extends Sprite
   {
      
      private var _selectIndex:int = 0;
      
      private var _suitPanel:SuitListPanel;
      
      private var _esuitPanel:SuitListPanel;
      
      private var _app:ApplicationDomain;
      
      private var _selectItem:BagTypeListItem;
      
      private var _listCon:Sprite;
      
      private var _outTime:uint;
      
      public function BagTypePanel(param1:ApplicationDomain)
      {
         var _loc2_:int = 0;
         var _loc3_:BagTypeListItem = null;
         super();
         this._app = param1;
         var _loc4_:Sprite = new (param1.getDefinition("bagtypepanelMc") as Class)() as Sprite;
         _loc4_.width = 104;
         _loc4_.cacheAsBitmap = true;
         addChild(_loc4_);
         this._listCon = new Sprite();
         this._listCon.x = 12;
         this._listCon.y = 15;
         addChild(this._listCon);
         var _loc5_:int = int(BagShowType.typeNameList.length);
         while(_loc2_ < _loc5_)
         {
            _loc3_ = new BagTypeListItem(this._app);
            _loc3_.setInfo(_loc2_,BagShowType.typeNameList[_loc2_]);
            _loc3_.y = _loc2_ * (_loc3_.height + 5);
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.onItemOver);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.onItemOut);
            _loc3_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            this._listCon.addChild(_loc3_);
            _loc2_++;
         }
         this._selectItem = this._listCon.getChildAt(BagShowType.currType) as BagTypeListItem;
         this._selectItem.select = true;
         _loc4_.height = this._listCon.height + 35;
      }
      
      public function setSelect(param1:int) : void
      {
         this._selectItem.select = false;
         this._selectItem = this._listCon.getChildAt(param1) as BagTypeListItem;
         this._selectItem.select = true;
      }
      
      private function suitDestroy() : void
      {
         if(Boolean(this._suitPanel))
         {
            this._suitPanel.removeEventListener(Event.SELECT,this.onSuitSelect);
            this._suitPanel.removeEventListener(MouseEvent.ROLL_OVER,this.onSuitOver);
            this._suitPanel.removeEventListener(MouseEvent.ROLL_OUT,this.onSuitOut);
            this._suitPanel.destroy();
            DisplayUtil.removeForParent(this._suitPanel);
            this._suitPanel = null;
         }
         if(Boolean(this._esuitPanel))
         {
            this._esuitPanel.removeEventListener(Event.SELECT,this.onSuitSelect);
            this._esuitPanel.removeEventListener(MouseEvent.ROLL_OVER,this.onSuitOver);
            this._esuitPanel.removeEventListener(MouseEvent.ROLL_OUT,this.onSuitOut);
            this._esuitPanel.destroy();
            DisplayUtil.removeForParent(this._esuitPanel);
            this._esuitPanel = null;
         }
      }
      
      private function onItemOver(param1:MouseEvent) : void
      {
         var _loc2_:BagTypeListItem = param1.currentTarget as BagTypeListItem;
         if(_loc2_.id == BagShowType.SUIT)
         {
            if(this._suitPanel == null)
            {
               this._suitPanel = new SuitListPanel(this._app);
               this._suitPanel.addEventListener(Event.SELECT,this.onSuitSelect);
               this._suitPanel.addEventListener(MouseEvent.ROLL_OVER,this.onSuitOver);
               this._suitPanel.addEventListener(MouseEvent.ROLL_OUT,this.onSuitOut);
               this._suitPanel.x = _loc2_.x + _loc2_.width + 10;
               this._suitPanel.y = -20;
            }
            addChild(this._suitPanel);
            clearTimeout(this._outTime);
         }
         else if(_loc2_.id == BagShowType.ELITE_SUIT)
         {
            if(this._esuitPanel == null)
            {
               this._esuitPanel = new SuitListPanel(this._app,true);
               this._esuitPanel.addEventListener(Event.SELECT,this.onSuitSelect);
               this._esuitPanel.addEventListener(MouseEvent.ROLL_OVER,this.onSuitOver);
               this._esuitPanel.addEventListener(MouseEvent.ROLL_OUT,this.onSuitOut);
               this._esuitPanel.x = _loc2_.x + _loc2_.width + 10;
               this._esuitPanel.y = -20;
            }
            addChild(this._esuitPanel);
            clearTimeout(this._outTime);
         }
      }
      
      private function onItemOut(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var item:BagTypeListItem = e.currentTarget as BagTypeListItem;
         if(item.id == BagShowType.SUIT)
         {
            if(Boolean(this._suitPanel))
            {
               clearTimeout(this._outTime);
               this._outTime = setTimeout(function():void
               {
                  suitDestroy();
               },500);
            }
         }
         if(item.id == BagShowType.ELITE_SUIT)
         {
            if(Boolean(this._esuitPanel))
            {
               clearTimeout(this._outTime);
               this._outTime = setTimeout(function():void
               {
                  suitDestroy();
               },500);
            }
         }
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:BagTypeListItem = param1.currentTarget as BagTypeListItem;
         if(_loc2_.id != BagShowType.SUIT)
         {
            dispatchEvent(new BagTypeEvent(BagTypeEvent.SELECT,_loc2_.id));
         }
      }
      
      private function onSuitSelect(param1:DynamicEvent) : void
      {
         dispatchEvent(new BagTypeEvent(BagTypeEvent.SELECT,BagShowType.SUIT,param1.paramObject as uint));
      }
      
      private function onSuitOver(param1:MouseEvent) : void
      {
         clearTimeout(this._outTime);
      }
      
      private function onSuitOut(param1:MouseEvent) : void
      {
         this.suitDestroy();
      }
   }
}

