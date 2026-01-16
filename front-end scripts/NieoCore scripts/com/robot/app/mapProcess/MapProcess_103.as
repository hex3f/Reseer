package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.*;
   import com.robot.app.energy.ore.*;
   import com.robot.app.equipStrengthen.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.book.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_103 extends BaseMapProcess
   {
      
      private var eggApp:AppModel;
      
      private var npcModel:NpcModel;
      
      private var timer:Timer;
      
      private var npcDialog:MovieClip;
      
      private var conVertDialog:MovieClip;
      
      private var boxMC:SimpleButton;
      
      private var bookMC:SimpleButton;
      
      private var bookBtn:MovieClip;
      
      private var _elietCoinBtn:SimpleButton;
      
      private var _aliceMc:MovieClip;
      
      private var _shopSo:SharedObject;
      
      private var appModel:AppModel;
      
      private var _so:SharedObject;
      
      public function MapProcess_103()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.boxMC = conLevel["box"];
         ToolTipManager.add(this.boxMC,"赛尔金豆");
         this.boxMC.visible = true;
         this.bookMC = conLevel["bookbox"];
         this.bookMC.visible = true;
         this.bookMC.addEventListener(MouseEvent.CLICK,this.onBookBoxClickHandler);
         ToolTipManager.add(this.bookMC,"宇宙购物指南");
         this._elietCoinBtn = conLevel["elietCoinBtn"];
         this._elietCoinBtn.visible = true;
         ToolTipManager.add(this._elietCoinBtn,"米币精品手册 ");
         this._elietCoinBtn.addEventListener(MouseEvent.CLICK,this.clickElietCoinHandler);
         this.bookBtn = btnLevel["book"];
         this.bookBtn.visible = true;
         this.bookBtn.addEventListener(MouseEvent.CLICK,this.showBookHandler);
         ToolTipManager.add(btnLevel["book"],"宇宙购物指南");
         this._so = SOManager.getUserSO(SOManager.READEDSHOPINGBOOK);
         if(!this._so.data.hasOwnProperty("isShow"))
         {
            this._so.data["isShow"] = false;
            SOManager.flush(this._so);
         }
         else if(this._so.data["isShow"] == true)
         {
            this.bookBtn["mc"].gotoAndStop(1);
            this.bookBtn["mc"].visible = false;
         }
         this.initShop();
      }
      
      private function clickElietCoinHandler(param1:MouseEvent) : void
      {
         BookManager.show(BookId.BOOK_0);
      }
      
      public function onEquipHandler() : void
      {
         EquipStrengthenController.start();
      }
      
      private function initShop() : void
      {
         this._shopSo = SOManager.getUserSO(SOManager.Is_Readed_ShopingBook);
         this.conLevel["shopMc"].addEventListener(MouseEvent.CLICK,this.onShopHandler);
         ToolTipManager.add(conLevel["shopMc"],"赛尔典藏手册");
      }
      
      private function onShopHandler(param1:MouseEvent) : void
      {
         BookManager.show(BookId.BOOK_4);
      }
      
      private function showBookHandler(param1:MouseEvent) : void
      {
         this._so.data["isShow"] = true;
         SOManager.flush(this._so);
         this.bookBtn["mc"].gotoAndStop(1);
         this.bookBtn["mc"].visible = false;
         this.showBook();
      }
      
      private function showBook() : void
      {
         BookManager.show(BookId.BOOK_3);
      }
      
      private function onBookBoxClickHandler(param1:MouseEvent) : void
      {
         this.showBook();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onTalk2);
         SocketConnection.send(CommandID.TALK_CATE,1003);
      }
      
      private function onTalk2(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onTalk2);
         DisplayUtil.removeForParent(conLevel["btn"]);
         Alarm.show("恭喜你获得" + TextFormatUtil.getRedTxt("10000点积累经验") + "，已经存入你的经验分配器中。快回基地看看吧");
      }
      
      private function onCount2(param1:Event) : void
      {
         if(DayOreCount.oreCount >= 1)
         {
            DisplayUtil.removeForParent(conLevel["btn"]);
         }
      }
      
      override public function destroy() : void
      {
         ItemAction.desBuyPanel();
         EquipStrengthenController.destory();
         BookManager.destroy();
         if(Boolean(this.eggApp))
         {
            this.eggApp = null;
         }
         if(Boolean(this._so))
         {
            this._so = null;
         }
      }
      
      public function onEggHandler() : void
      {
         if(!this.eggApp)
         {
            this.eggApp = new AppModel(ClientConfig.getGameModule("EggMechineGame"),"正在打开扭蛋机");
         }
         this.eggApp.show();
      }
      
      public function buyItem() : void
      {
         var _loc1_:DayOreCount = new DayOreCount();
         _loc1_.addEventListener(DayOreCount.countOK,this.onCount);
         _loc1_.sendToServer(2051);
      }
      
      private function onCount(param1:Event) : void
      {
         if(DayOreCount.oreCount >= 1)
         {
            Alarm.show("你今天已经领取过了");
         }
         else
         {
            SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onTalk);
            SocketConnection.send(CommandID.TALK_CATE,2051);
         }
      }
      
      private function onTalk(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onTalk);
         ItemInBagAlert.show(400501,"2个<font color=\'#ff0000\'>神奇扭蛋牌</font>已经放入你的储存箱中！");
      }
   }
}

