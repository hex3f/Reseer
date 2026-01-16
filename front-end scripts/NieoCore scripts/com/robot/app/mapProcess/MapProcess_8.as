package com.robot.app.mapProcess
{
   import com.robot.app.buyCloth.*;
   import com.robot.app.buyItem.*;
   import com.robot.app.games.waterGunGame.*;
   import com.robot.app.help.*;
   import com.robot.app.task.noviceGuide.*;
   import com.robot.app.task.pioneerTaskList.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.config.*;
   import com.robot.core.event.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.book.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.npc.*;
   import com.robot.core.ui.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.SharedObject;
   import flash.utils.*;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_8 extends BaseMapProcess
   {
      
      private var _buyBtn:SimpleButton;
      
      private var _repairBtn:SimpleButton;
      
      private var _btnNpc:Sprite;
      
      private var _inID:uint;
      
      private var ciciMC:NpcModel;
      
      private var dialogTimer:Timer;
      
      private var xixi:String;
      
      private var _doodlePanel:AppModel;
      
      private var _isShow:Boolean = false;
      
      private var repairPanel:AppModel;
      
      private var halfIcon:MovieClip;
      
      private var _arrowHeadMC:MovieClip;
      
      private var _shopSo:SharedObject;
      
      private var _elietCoinBtn:SimpleButton;
      
      private var _bookApp:AppModel;
      
      private var _machPanel:MovieClip;
      
      private var wbMc:MovieClip;
      
      private var mbox:DialogBox;
      
      private var drillInBagMC:MovieClip;
      
      private var npc:NpcModel;
      
      public function MapProcess_8()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._machPanel = MapLibManager.getMovieClip("GetMachPanel");
         if(MainManager.actorInfo.loginCnt == 0)
         {
            if(!MainManager.checkIsNovice())
            {
               XixiDialog.showNew();
            }
            MainManager.actorInfo.loginCnt = 1;
         }
         ToolTipManager.add(conLevel["itemBtn"],"领取挖矿钻头");
         this._repairBtn = conLevel["repairBtn"];
         this._repairBtn.addEventListener(MouseEvent.CLICK,this.openRepair);
         this._buyBtn = conLevel["buyBtn"];
         this._buyBtn.addEventListener(MouseEvent.CLICK,this.buyHandler);
         this._shopSo = SOManager.getUserSO(SOManager.Is_Readed_ShopingBook);
         this.conLevel["shopMc"].addEventListener(MouseEvent.CLICK,this.onShopHandler);
         this.dialogTimer = new Timer(10 * 1000);
         this.dialogTimer.addEventListener(TimerEvent.TIMER,this.showDialog);
         this.dialogTimer.start();
         this.xixi = NpcTipDialog.CICI;
         var _loc1_:DialogBox = new DialogBox();
         this._elietCoinBtn = conLevel["elietCoinBtn"];
         ToolTipManager.add(conLevel["shopMc"],"赛尔典藏手册");
         ToolTipManager.add(this._buyBtn,"赛尔工厂");
         ToolTipManager.add(conLevel["getMach_btn"],"特殊装置领取舱");
         ToolTipManager.add(conLevel["buyBtn2"],"赛尔工厂");
         ToolTipManager.add(conLevel["color_door"],"涂装室");
         ToolTipManager.add(conLevel["repairBtn"],"装备修复机");
         ToolTipManager.add(this._elietCoinBtn,"米币精品手册 ");
         this._elietCoinBtn.addEventListener(MouseEvent.CLICK,this.clickElietCoinHandler);
         this.wbMc = conLevel["hitWbMC"];
         this.wbMc.addEventListener(MouseEvent.MOUSE_OVER,this.wbmcOverHandler);
         this.wbMc.addEventListener(MouseEvent.MOUSE_OUT,this.wbmcOUTHandler);
         this.halfIcon = MapLibManager.getMovieClip("half_icon");
         this.halfIcon.mouseChildren = false;
         this.halfIcon.mouseEnabled = false;
         if(MainManager.isClothHalfDay)
         {
            this.halfIcon.x = 885;
            this.halfIcon.y = 380;
            conLevel.addChild(this.halfIcon);
         }
         this.wbMc.addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
         this._arrowHeadMC = conLevel["arrowHeadMC"];
         this._arrowHeadMC.visible = false;
         this.initTask_94();
      }
      
      private function clickElietCoinHandler(param1:MouseEvent) : void
      {
         BookManager.show(BookId.BOOK_0);
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         if(Boolean(NpcController.curNpc))
         {
            this.wbMc.removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
         }
      }
      
      public function funHitDoor() : void
      {
         MapManager.changeLocalMap(513);
      }
      
      private function onShopHandler(param1:MouseEvent) : void
      {
         this.showShopBook();
      }
      
      private function showShopBook() : void
      {
         if(!this._bookApp)
         {
            this._bookApp = new AppModel(ClientConfig.getBookModule("SeerBookReservationPanel"),"正在打开");
            this._bookApp.setup();
         }
         this._bookApp.show();
      }
      
      private function showDialog(param1:TimerEvent) : void
      {
         var _loc2_:DialogBox = new DialogBox();
      }
      
      public function showWBTask() : void
      {
         HelpManager.show(0);
      }
      
      private function showTip(param1:MouseEvent) : void
      {
         NpcTipDialog.show("这里是 ，机器人赛尔的装备库。你在这里可以购买和修复装备，还可以给自己选一套超炫的涂装。");
      }
      
      private function openRepair(param1:MouseEvent) : void
      {
         if(!this.repairPanel)
         {
            this.repairPanel = new AppModel(ClientConfig.getAppModule("RepairItemPanel"),"正在打开修复装置");
            this.repairPanel.setup();
         }
         this.repairPanel.show();
      }
      
      public function buyHandler(param1:MouseEvent = null) : void
      {
         BuyClothController.show();
      }
      
      public function changeToGround() : void
      {
      }
      
      public function onColor() : void
      {
         if(this._doodlePanel == null)
         {
            this._doodlePanel = new AppModel(ClientConfig.getAppModule("DoodlePanel"),"正在打开涂装面板");
            this._doodlePanel.setup();
            this._doodlePanel.sharedEvents.addEventListener(Event.OPEN,this.onDoodleOpen);
            this._doodlePanel.sharedEvents.addEventListener(Event.CLOSE,this.onDoodleClose);
         }
         this._doodlePanel.show();
      }
      
      public function buyItem() : void
      {
         ItemAction.buyItem(100014,false);
      }
      
      public function onMachHandler() : void
      {
         LevelManager.appLevel.addChild(this._machPanel);
         DisplayUtil.align(this._machPanel,null,AlignType.MIDDLE_CENTER);
         this._machPanel["close_btn"].addEventListener(MouseEvent.CLICK,this.clickMachCloseHandler);
         this._machPanel["ship_btn"].addEventListener(MouseEvent.CLICK,this.onShipHandler);
         this._machPanel["fire_btn"].addEventListener(MouseEvent.CLICK,this.onFireHandler);
         this._machPanel["wateGameBtn"].addEventListener(MouseEvent.CLICK,this.showWaterGame);
      }
      
      public function onFireHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.clickMachCloseHandler();
         NpcTipDialog.show("喷火枪的燃料是高纯度的氢气和氧气，只有按照合适比例混合后点燃，才能爆出最大的火焰。你先试用下这个喷火装置，看看你能不能搞定这个危险大家伙！",function():void
         {
            var _loc1_:HOTestTask = new HOTestTask();
         },NpcTipDialog.DOCTOR,-60);
      }
      
      public function onShipHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.clickMachCloseHandler();
         NpcTipDialog.show("潜水套装可以让赛尔承受海底的巨大压力，潜入深水去寻找矿藏。潜水套装里面有个电路，正确连接电路就可以启动它。你先拿这个模型练练手！",function():void
         {
            var _loc1_:BatteryTestTask = new BatteryTestTask();
         },NpcTipDialog.CICI,-60);
      }
      
      private function clickMachCloseHandler(param1:MouseEvent = null) : void
      {
         DisplayUtil.removeForParent(this._machPanel);
      }
      
      public function showWaterGame(param1:MouseEvent) : void
      {
         this.clickMachCloseHandler();
         NpcTipDialog.show("喷水装备可以用于灭火，强力水柱还能够击破碎石。你在火山星任务中会用到它。考考你，同一支水枪如何打到最远。",this.startWaterGame,this.xixi,-60);
      }
      
      private function startWaterGame() : void
      {
         WaterGunGame.loadGame();
      }
      
      private function wbmcOverHandler(param1:MouseEvent) : void
      {
         this.mbox = new DialogBox();
         this.mbox.show("有什么需要我帮助您的吗？",0,-30,conLevel["wbNpc"]);
      }
      
      private function wbmcOUTHandler(param1:MouseEvent) : void
      {
         this.mbox.hide();
      }
      
      public function showWbAction() : void
      {
         var _loc1_:MovieClip = conLevel["wbNpc"] as MovieClip;
         _loc1_.gotoAndPlay(2);
      }
      
      override public function destroy() : void
      {
         ItemAction.desBuyPanel();
         ToolTipManager.remove(conLevel["itemBtn"]);
         DisplayUtil.removeForParent(this.halfIcon);
         this.halfIcon = null;
         this.wbMc.removeEventListener(MouseEvent.MOUSE_OVER,this.wbmcOverHandler);
         this.wbMc.removeEventListener(MouseEvent.MOUSE_OUT,this.wbmcOUTHandler);
         this.wbMc = null;
         this.mbox = null;
         this.dialogTimer.stop();
         this.dialogTimer.removeEventListener(TimerEvent.TIMER,this.showDialog);
         this.dialogTimer = null;
         clearTimeout(this._inID);
         this._buyBtn.removeEventListener(MouseEvent.CLICK,this.buyHandler);
         this._repairBtn.removeEventListener(MouseEvent.CLICK,this.openRepair);
         this.xixi = null;
         ToolTipManager.remove(this._buyBtn);
         ToolTipManager.remove(conLevel["wateGameBtn"]);
         ToolTipManager.remove(conLevel["ship_btn"]);
         ToolTipManager.remove(conLevel["buyBtn2"]);
         ToolTipManager.remove(conLevel["color_door"]);
         ToolTipManager.remove(conLevel["repairBtn"]);
         if(Boolean(this._doodlePanel))
         {
            this._doodlePanel.sharedEvents.removeEventListener(Event.OPEN,this.onDoodleOpen);
            this._doodlePanel.sharedEvents.removeEventListener(Event.CLOSE,this.onDoodleClose);
            this._doodlePanel.destroy();
            this._doodlePanel = null;
         }
         if(Boolean(this.repairPanel))
         {
            this.repairPanel.destroy();
            this.repairPanel = null;
         }
         BuyClothController.destroy();
         if(Boolean(this._bookApp))
         {
            this._bookApp.destroy();
            this._bookApp = null;
         }
         conLevel["shopMc"].removeEventListener(MouseEvent.CLICK,this.onShopHandler);
         this._shopSo = null;
         ToolTipManager.remove(conLevel["shopMc"]);
      }
      
      private function onDoodleOpen(param1:Event) : void
      {
         var e:Event = param1;
         this._inID = setTimeout(function():void
         {
            MainManager.actorModel.sprite.x = 225;
            MainManager.actorModel.sprite.y = 90;
         },500);
      }
      
      private function onDoodleClose(param1:Event) : void
      {
         var e:Event = param1;
         this._inID = setTimeout(function():void
         {
            MainManager.actorModel.sprite.x = 332;
            MainManager.actorModel.sprite.y = 115;
         },1000);
      }
      
      private function initTask_94() : void
      {
         if(TasksManager.getTaskStatus(94) == TasksManager.UN_ACCEPT)
         {
            TasksManager.addListener(TaskEvent.ACCEPT,94,0,this.onAcceptTask);
         }
         else
         {
            TasksManager.getProStatusList(94,function(param1:Array):void
            {
               if(!param1[0])
               {
                  onAcceptTask();
               }
               if(Boolean(param1[0]) && !param1[1])
               {
                  _arrowHeadMC.visible = true;
               }
            });
         }
      }
      
      private function onAcceptTask(param1:TaskEvent = null) : void
      {
         var evt:TaskEvent = param1;
         TasksManager.removeListener(TaskEvent.ACCEPT,94,0,this.onAcceptTask);
         this.drillInBagMC = MapLibManager.getMovieClip("DrillInBagMC");
         LevelManager.topLevel.addChild(this.drillInBagMC);
         this.drillInBagMC.x = 437;
         this.drillInBagMC.y = 333;
         this.drillInBagMC.gotoAndPlay(2);
         this.drillInBagMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            if(drillInBagMC.currentFrame == drillInBagMC.totalFrames)
            {
               drillInBagMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(drillInBagMC);
               ItemManager.addEventListener(ItemEvent.CLOTH_LIST,onHasClothOne);
               ItemManager.getCloth();
            }
         });
      }
      
      private function onHasClothOne(param1:ItemEvent) : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,this.onHasClothOne);
         if(ItemManager.containsCloth(100014))
         {
            this.completeTask_0();
         }
         else
         {
            ItemAction.buyItem(100014,false);
            EventManager.addEventListener(ItemAction.BUY_ONE,this.onGetItemOne);
         }
      }
      
      private function onGetItemOne(param1:DynamicEvent) : void
      {
         if(uint(param1.paramObject) == 100014)
         {
            EventManager.removeEventListener(ItemAction.BUY_ONE,this.onGetItemOne);
            this.completeTask_0();
         }
      }
      
      private function completeTask_0() : void
      {
         NpcDialog.show(NPC.CICI,["有些星球还饱含大量的气态能源，需要用0xff0000气体收集器0xffffff才能收集到！如果你有需要，可以在机械室的0xff0000赛尔工厂0xffffff购买哦。当然，天下没有免费的午餐！#8"],["好！我这就去看看！"],[function():void
         {
            TasksManager.complete(94,0,null,true);
            _arrowHeadMC.visible = true;
         }]);
      }
   }
}

