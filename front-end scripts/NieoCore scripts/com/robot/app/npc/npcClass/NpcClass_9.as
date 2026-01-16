package com.robot.app.npc.npcClass
{
   import com.robot.app.buyItem.ProductAction;
   import com.robot.app.newspaper.ContributeAlert;
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.npc.NpcInfo;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class NpcClass_9 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      private var conVertDialog:MovieClip;
      
      private var _box:SimpleButton;
      
      private var _loader:MCLoader;
      
      private var _content:MovieClip;
      
      private var _needSeerBean:int = 0;
      
      public function NpcClass_9(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this.conVertDialog = MapLibManager.getMovieClip("BeanPanel");
         this._box = MapManager.currentMap.controlLevel["box"];
         this._box.addEventListener(MouseEvent.CLICK,this.convertBeanDialog);
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
      }
      
      private function onClickNpc(param1:NpcEvent) : void
      {
         NpcDialog.show(NPC.ROCKY,["嗨！小赛尔你好呀，我是来自火星基地的百事通罗开，有什么问题你尽管问我吧！"],["我想了解金豆","我有一些关于金豆道具的建议哦！"],[this.handlerOne,this.handlerThree]);
      }
      
      private function handlerOne() : void
      {
         this.loadBeanInfoSwf();
      }
      
      private function change() : void
      {
         NpcDialog.show(NPC.ROCKY,["请选择兑换金豆方式"],["优惠兑换（固定兑换一定数量的金豆，需要赛尔豆数量随兑换次数累加）","直接兑换（直接兑换一定数量的金豆，需要赛尔豆数量不变）","还是算了"],[this.exchangeOne,this.exchangeTwo]);
      }
      
      private function exchangeOne() : void
      {
         SocketConnection.addCmdListener(CommandID.GET_CURRENT_GOLD_NIEOBEAN,this.showExchangeGold);
         SocketConnection.send(CommandID.GET_CURRENT_GOLD_NIEOBEAN);
      }
      
      private function exchangeTwo() : void
      {
         NpcDialog.show(NPC.ROCKY,["赛尔金豆礼包多多、满意多多，欢迎选购！"],["1万赛尔豆兑换1金豆","5W赛尔豆兑换5金豆","10W赛尔豆兑换10金豆","还是算了"],[this.exchangeGoldTwo,this.exchangeGoldThree,this.exchangeGoldFour]);
      }
      
      private function showExchangeGold(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GET_CURRENT_GOLD_NIEOBEAN,this.showExchangeGold);
         var _loc2_:ByteArray = param1.data as ByteArray;
         this._needSeerBean = _loc2_.readUnsignedInt();
         NpcDialog.show(NPC.ROCKY,["赛尔金豆礼包多多、满意多多，欢迎选购！"],[this._needSeerBean + "赛尔豆兑换30金豆","还是算了"],[this.exchangeGoldOne]);
      }
      
      private function exchangeGoldOne() : void
      {
         Alert.show("你确定要使用" + this._needSeerBean + "赛尔豆兑换30金豆吗?",function():void
         {
            if(MainManager.actorInfo.coins < _needSeerBean)
            {
               Alarm.show("小赛尔，你的赛尔豆不足，无法兑换金豆！");
               return;
            }
            SocketConnection.send(CommandID.EXCHANGE_GOLD_NIEOBEAN,0);
         });
      }
      
      private function exchangeGoldTwo() : void
      {
         Alert.show("你确定要使用10000赛尔豆兑换1金豆吗?",function():void
         {
            if(MainManager.actorInfo.coins < 10000)
            {
               Alarm.show("小赛尔，你的赛尔豆不足，无法兑换金豆！");
               return;
            }
            SocketConnection.send(CommandID.EXCHANGE_GOLD_NIEOBEAN,1);
         });
      }
      
      private function exchangeGoldThree() : void
      {
         Alert.show("你确定要使用50000赛尔豆兑换5金豆吗?",function():void
         {
            if(MainManager.actorInfo.coins < 50000)
            {
               Alarm.show("小赛尔，你的赛尔豆不足，无法兑换金豆！");
               return;
            }
            SocketConnection.send(CommandID.EXCHANGE_GOLD_NIEOBEAN,5);
         });
      }
      
      private function exchangeGoldFour() : void
      {
         Alert.show("你确定要使用100000赛尔豆兑换10金豆吗?",function():void
         {
            if(MainManager.actorInfo.coins < 100000)
            {
               Alarm.show("小赛尔，你的赛尔豆不足，无法兑换金豆！");
               return;
            }
            SocketConnection.send(CommandID.EXCHANGE_GOLD_NIEOBEAN,10);
         });
      }
      
      private function handlerThree() : void
      {
         NpcDialog.show(NPC.ROCKY,["你是个充满智慧的小赛尔，找到我可算你有眼光了！想要什么呢？尽管和我说吧！我想我们火星港一定能够为你提供最前面的服务！"],["我这就写信和你说！","还是等等吧..."],[this.write]);
      }
      
      private function write() : void
      {
         ContributeAlert.show(ContributeAlert.ROCKY);
      }
      
      private function loadBeanInfoSwf() : void
      {
         this._loader = new MCLoader("resource/book/beaninfo.swf",LevelManager.topLevel,1,"正在打开");
         this._loader.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         this._loader.doLoad();
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoad);
         this._content = param1.getContent() as MovieClip;
         LevelManager.appLevel.addChild(this._content);
         DisplayUtil.align(this._content,null,AlignType.MIDDLE_CENTER);
         this._content["close_btn"].addEventListener(MouseEvent.CLICK,this.onCloseHandler);
      }
      
      private function onCloseHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._content);
      }
      
      private function convertBeanDialog(param1:MouseEvent) : void
      {
         NpcDialog.show(NPC.ROCKY,["我带来的所有最in、最hot的商品都必须用赛尔金豆才可以换取哟！嗯？你现在就准备换取赛尔金豆吗？"],["哟呼！我已经准备好咯！","嗯……我还是稍后再来换取吧！"],[this.change]);
      }
      
      private function onBtnClickHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget.name)
         {
            case "tenbean":
               ProductAction.buyMoneyProduct(200000);
               break;
            case "fiftybean":
               ProductAction.buyMoneyProduct(200001);
               break;
            case "percentbean":
               ProductAction.buyMoneyProduct(200002);
               break;
            case "closeBtn":
               DisplayUtil.removeForParent(this.conVertDialog);
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.removeEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
            this._curNpcModel.destroy();
            this._curNpcModel = null;
         }
         if(Boolean(this._box))
         {
            this._box.removeEventListener(MouseEvent.CLICK,this.convertBeanDialog);
         }
         if(Boolean(this._loader))
         {
            this._loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoad);
            this._loader.clear();
            this._loader = null;
         }
         if(Boolean(this._content))
         {
            this._content["close_btn"].removeEventListener(MouseEvent.CLICK,this.onCloseHandler);
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

