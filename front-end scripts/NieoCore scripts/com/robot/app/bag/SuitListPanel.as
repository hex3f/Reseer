package com.robot.app.bag
{
   import com.robot.core.config.xml.SuitXMLInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.uic.UIPageBar;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import org.taomee.events.DynamicEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class SuitListPanel extends Sprite
   {
      
      private static const MAX:int = 6;
      
      private var _dataList:Array;
      
      private var _listCon:Sprite;
      
      private var _dataLen:int = 0;
      
      private var _proPageBar:UIPageBar;
      
      public function SuitListPanel(param1:ApplicationDomain, param2:Boolean = false)
      {
         var bg:Sprite = null;
         var _dataLen:int = 0;
         var len:int = 0;
         var i:int = 0;
         var _preBtn:SimpleButton = null;
         var _nextBtn:SimpleButton = null;
         var app:ApplicationDomain = param1;
         var isE:Boolean = param2;
         var id:uint = 0;
         var item:BagTypeListItem = null;
         super();
         bg = new (app.getDefinition("suitpanelMc") as Class)() as Sprite;
         bg.width = 120;
         bg.height = 276;
         bg.cacheAsBitmap = true;
         addChild(bg);
         this._listCon = new Sprite();
         this._listCon.x = 10;
         this._listCon.y = 34;
         addChild(this._listCon);
         if(isE)
         {
            this._dataList = SuitXMLInfo.getIsEliteItems(ItemManager.getClothIDs());
         }
         else
         {
            this._dataList = SuitXMLInfo.getIDsForItems(ItemManager.getClothIDs());
         }
         if(BagPanel.currTab == BagTabType.NONO)
         {
            this._dataList = this._dataList.filter(function(param1:uint, param2:int, param3:Array):Boolean
            {
               if(SuitXMLInfo.getIsVip(param1))
               {
                  return true;
               }
               return false;
            });
         }
         else
         {
            this._dataList = this._dataList.filter(function(param1:uint, param2:int, param3:Array):Boolean
            {
               if(!SuitXMLInfo.getIsVip(param1))
               {
                  return true;
               }
               return false;
            });
         }
         _dataLen = int(this._dataList.length);
         len = Math.min(MAX,_dataLen);
         i = 0;
         while(i < MAX)
         {
            id = uint(this._dataList[i]);
            item = new BagTypeListItem(app);
            item.width = 96;
            item.y = i * (item.height + 5);
            this._listCon.addChild(item);
            if(i < len)
            {
               item.setInfo(id,SuitXMLInfo.getName(id));
               item.addEventListener(MouseEvent.CLICK,this.onItemClick);
               if(BagShowType.currType == BagShowType.SUIT)
               {
                  if(item.id == BagShowType.currSuitID)
                  {
                     item.select = true;
                  }
               }
            }
            i++;
         }
         _preBtn = UIManager.getButton("Arrow_Icon");
         _preBtn.x = bg.width / 2 + _preBtn.width / 2;
         _preBtn.y = 5;
         _preBtn.rotation = 90;
         addChild(_preBtn);
         _nextBtn = UIManager.getButton("Arrow_Icon");
         _nextBtn.x = (bg.width - _nextBtn.width) / 2;
         _nextBtn.y = bg.height - 10;
         _nextBtn.rotation = -90;
         addChild(_nextBtn);
         this._proPageBar = new UIPageBar(_preBtn,_nextBtn,new TextField(),MAX);
         this._proPageBar.totalLength = _dataLen;
         this._proPageBar.addEventListener(MouseEvent.CLICK,this.onProPage);
      }
      
      public function destroy() : void
      {
         this._proPageBar.removeEventListener(MouseEvent.CLICK,this.onProPage);
         this._proPageBar.destroy();
         this._proPageBar = null;
         this._dataList = null;
         DisplayUtil.removeAllChild(this);
         this._listCon = null;
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:BagTypeListItem = param1.currentTarget as BagTypeListItem;
         dispatchEvent(new DynamicEvent(Event.SELECT,_loc2_.id));
      }
      
      private function onProPage(param1:DynamicEvent) : void
      {
         var _loc2_:BagTypeListItem = null;
         var _loc3_:* = 0;
         var _loc4_:BagTypeListItem = null;
         var _loc5_:uint = param1.paramObject as uint;
         var _loc6_:int = 0;
         while(_loc6_ < MAX)
         {
            _loc2_ = this._listCon.getChildAt(_loc6_) as BagTypeListItem;
            _loc2_.clear();
            _loc6_++;
         }
         var _loc7_:int = Math.min(MAX,this._proPageBar.totalLength - this._proPageBar.index * MAX);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            _loc3_ = uint(this._dataList[_loc8_ + _loc5_ * MAX]);
            _loc4_ = this._listCon.getChildAt(_loc8_) as BagTypeListItem;
            _loc4_.setInfo(_loc3_,SuitXMLInfo.getName(_loc3_));
            if(BagShowType.currType == BagShowType.SUIT)
            {
               if(_loc4_.id == BagShowType.currSuitID)
               {
                  _loc4_.select = true;
               }
               else
               {
                  _loc4_.select = false;
               }
            }
            _loc8_++;
         }
      }
   }
}

