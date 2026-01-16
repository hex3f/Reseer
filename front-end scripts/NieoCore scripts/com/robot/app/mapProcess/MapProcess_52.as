package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.*;
   import com.robot.app.mapProcess.active.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.app.vipSession.*;
   import com.robot.core.*;
   import com.robot.core.aimat.*;
   import com.robot.core.dayGift.*;
   import com.robot.core.event.*;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.info.task.DayTalkInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_52 extends BaseMapProcess
   {
      
      private var _leaf:MovieClip;
      
      private var _flower:MovieClip;
      
      private var _bao_0:MovieClip;
      
      private var _bao_1:MovieClip;
      
      private var _btn_0:SimpleButton;
      
      private var _btn_1:SimpleButton;
      
      private var _b_0:SimpleButton;
      
      private var _b_1:SimpleButton;
      
      private var _nono_mc:MovieClip;
      
      private var _time:Timer;
      
      private var star:ActiveStar;
      
      private var an:uint = 0;
      
      private var col:uint;
      
      public function MapProcess_52()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.star = new ActiveStar(new Point(-100),new Point(780));
         this.reIntball();
         this._nono_mc = conLevel["nono_mc"];
         this._nono_mc.gotoAndStop(1);
         this._nono_mc["nono_mc"].gotoAndStop(1);
         this._nono_mc["nono_mc"]["nono_mc"].gotoAndStop(1);
         this._nono_mc["nono_mc"]["tree_mc"].gotoAndStop(1);
         this._nono_mc.buttonMode = true;
         this._nono_mc.addEventListener(MouseEvent.CLICK,this.clickTreeHandler);
         this._nono_mc.addEventListener("sendqingmidu",this.qimiHandler);
         this._time = new Timer(1000,0);
         this._time.addEventListener(TimerEvent.TIMER,this.timerEnterHandler);
         this._time.start();
         this._leaf = conLevel["leaf"];
         this._leaf.gotoAndStop(1);
         this._leaf.buttonMode = true;
         this._leaf.addEventListener(MouseEvent.CLICK,this.clickLeaf);
         this._flower = conLevel["flower"];
         this._flower.buttonMode = true;
         this._flower.gotoAndStop(1);
         this._flower.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
         {
            _flower.gotoAndStop(2);
         });
         this._flower.addEventListener(MouseEvent.ROLL_OUT,function(param1:MouseEvent):void
         {
            _flower.gotoAndStop(1);
         });
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimatEnd);
      }
      
      public function onLevelHandler() : void
      {
         Alert.show("你确定要离开这里吗?",function():void
         {
            MapManager.changeMap(51);
         });
      }
      
      private function onAimatEnd(param1:AimatEvent) : void
      {
         var p:Point = null;
         var id:uint = 0;
         var evt:AimatEvent = param1;
         if(MainManager.actorID != evt.info.userID)
         {
            return;
         }
         p = evt.info.endPos;
         id = uint(evt.info.id);
         if(this._flower.hitTestPoint(p.x,p.y))
         {
            if(id == 600002)
            {
               this._flower.gotoAndStop(3);
               setTimeout(function():void
               {
                  NpcTipDialog.show("喂，你还真的扔我啊？⊙﹏⊙傻孩子，这是斯诺星特产的斯诺天气弹，抛向空中，你会看到美丽的天气变化。",null,NpcTipDialog.FLOWER);
               },1500);
            }
         }
      }
      
      private function qimiHandler(param1:Event) : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_MATE_CHANGE,this.nonoMateChange);
         SocketConnection.send(CommandID.NONO_MATE_CHANGE);
         MainManager.actorModel.hideNono();
      }
      
      private function nonoMateChange(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.NONO_MATE_CHANGE,this.nonoMateChange);
         NonoManager.info.mate = 100;
         NpcTipDialog.show("O(∩_∩)O呵呵~\n    NoNo好开心，精神满满哟！",null,NpcTipDialog.NONO);
      }
      
      private function timerEnterHandler(param1:TimerEvent) : void
      {
         ++this.an;
         if(this.an >= 60)
         {
            this.an = 0;
            this.removeAdd();
            this.reIntball();
         }
      }
      
      private function nonoMcEnterFrame(param1:Event) : void
      {
         if(this._nono_mc.currentFrame == 2 && Boolean(this._nono_mc.nono_mc))
         {
            if(Boolean(this._nono_mc.nono_mc.no_mc))
            {
               this._nono_mc.removeEventListener(Event.ENTER_FRAME,this.nonoMcEnterFrame);
               DisplayUtil.FillColor(this._nono_mc.nono_mc.no_mc,this.col);
            }
         }
      }
      
      private function clickTreeHandler(param1:MouseEvent) : void
      {
         if(!MainManager.actorInfo.superNono || MainManager.actorModel.nono == null)
         {
            NpcTipDialog.show("~ ~ (╯﹏╰) ~ ~\n你都没有带着超能NoNo，快点带我一块玩！",null,NpcTipDialog.NONO);
         }
         else
         {
            this.col = MainManager.actorInfo.nonoColor;
            if(NonoManager.info.superLevel < 4)
            {
               this._nono_mc.gotoAndStop(2);
               this._nono_mc.addEventListener(Event.ENTER_FRAME,this.nonoMcEnterFrame);
            }
            else
            {
               this._nono_mc["nono_mc"];
               this._nono_mc["nono_mc"].gotoAndPlay(2);
               this._nono_mc["nono_mc"]["nono_mc"].gotoAndPlay(2);
               this._nono_mc["nono_mc"]["tree_mc"].gotoAndPlay(2);
               this._nono_mc["nono_mc"]["bai_mc"].gotoAndPlay(2);
               DisplayUtil.FillColor(this._nono_mc["nono_mc"]["bai_mc"],this.col);
            }
            this._nono_mc.buttonMode = false;
            this._nono_mc.removeEventListener(MouseEvent.CLICK,this.clickTreeHandler);
            NonoManager.info.mate = 100;
            MainManager.actorModel.hideNono();
         }
      }
      
      private function removeAdd() : void
      {
         this._btn_1.removeEventListener(MouseEvent.CLICK,this.oneClickHandler);
         this._btn_0.removeEventListener(MouseEvent.CLICK,this.zeroClickHandler);
         this._b_0.removeEventListener(MouseEvent.CLICK,this.clickB0Handler);
         this._b_1.removeEventListener(MouseEvent.CLICK,this.clickB1Handler);
         this._btn_1.visible = false;
         this._btn_0.visible = false;
         this._b_0.visible = false;
         this._b_1.visible = false;
      }
      
      private function reIntball() : void
      {
         var _loc1_:Array = null;
         var _loc2_:uint = 0;
         var _loc4_:uint = 0;
         _loc1_ = new Array(0,1,2,3,4,5);
         var _loc3_:Array = new Array();
         while(_loc4_ < 2)
         {
            _loc2_ = uint(Math.random() * _loc1_.length);
            _loc3_.push(_loc1_[_loc2_]);
            _loc1_.splice(_loc2_,1);
            _loc4_++;
         }
         this._bao_0 = conLevel["bao_" + _loc3_[0]];
         this._bao_1 = conLevel["bao_" + _loc3_[1]];
         this._btn_0 = conLevel["btn_" + _loc3_[0]];
         this._btn_1 = conLevel["btn_" + _loc3_[1]];
         this._b_0 = conLevel["b_" + _loc3_[0]];
         this._b_1 = conLevel["b_" + _loc3_[1]];
         this._bao_0.gotoAndStop(1);
         this._bao_1.gotoAndStop(1);
         this._btn_0.visible = true;
         this._btn_1.visible = true;
         conLevel["bao_" + _loc1_[0]].gotoAndStop(5);
         conLevel["bao_" + _loc1_[1]].gotoAndStop(5);
         conLevel["bao_" + _loc1_[2]].gotoAndStop(5);
         conLevel["bao_" + _loc1_[3]].gotoAndStop(5);
         conLevel["btn_" + _loc1_[0]].visible = false;
         conLevel["btn_" + _loc1_[1]].visible = false;
         conLevel["btn_" + _loc1_[2]].visible = false;
         conLevel["btn_" + _loc1_[3]].visible = false;
         this._btn_1.addEventListener(MouseEvent.CLICK,this.oneClickHandler);
         this._btn_0.addEventListener(MouseEvent.CLICK,this.zeroClickHandler);
         this._b_0.addEventListener(MouseEvent.CLICK,this.clickB0Handler);
         this._b_1.addEventListener(MouseEvent.CLICK,this.clickB1Handler);
         _loc1_ = null;
         _loc3_ = null;
      }
      
      private function clickB0Handler(param1:MouseEvent) : void
      {
         this._b_0.removeEventListener(MouseEvent.CLICK,this.clickB0Handler);
         this._bao_0.gotoAndStop(5);
         this.getBears(13,"绿斯诺豌豆",5);
      }
      
      private function clickB1Handler(param1:MouseEvent) : void
      {
         this._b_1.removeEventListener(MouseEvent.CLICK,this.clickB1Handler);
         this._bao_1.gotoAndStop(5);
         this.getBears(13,"绿斯诺豌豆",5);
      }
      
      private function getBears(param1:uint, param2:String, param3:uint) : void
      {
         var type:uint = param1;
         var str:String = param2;
         var n:uint = param3;
         var a:DayGiftController = new DayGiftController(type,n,"今天已经得到" + String(n) + "颗了",true);
         a.sendToServer(function(param1:DayTalkInfo):void
         {
            NpcTipDialog.show("你得到了" + param1.outCount + "颗" + str + "。" + str + "已经放入你的背包里了。",null,NpcTipDialog.NONO,-80);
         });
      }
      
      private function oneClickHandler(param1:MouseEvent) : void
      {
         this._btn_1.removeEventListener(MouseEvent.CLICK,this.oneClickHandler);
         if(this._bao_1.currentFrame == 2)
         {
            this._bao_1.gotoAndStop(3);
         }
         else if(this._bao_1.currentFrame == 1)
         {
            if(MainManager.actorInfo.superNono)
            {
               if(this._bao_1.bao_mc["zi_mc"].currentFrame < 128)
               {
                  this.getBears(2053,"橙斯诺豌豆",10);
               }
               else
               {
                  this.getBears(2052,"黄斯诺豌豆",10);
               }
               this._bao_1.gotoAndStop(5);
            }
         }
      }
      
      private function zeroClickHandler(param1:MouseEvent) : void
      {
         this._btn_0.removeEventListener(MouseEvent.CLICK,this.zeroClickHandler);
         if(this._bao_0.currentFrame == 2)
         {
            this._bao_0.gotoAndStop(3);
         }
         else if(this._bao_0.currentFrame == 1)
         {
            if(MainManager.actorInfo.superNono)
            {
               if(this._bao_0.bao_mc["zi_mc"].currentFrame < 128)
               {
                  this.getBears(2053,"橙斯诺豌豆",10);
               }
               else
               {
                  this.getBears(2052,"黄斯诺豌豆",10);
               }
               this._bao_0.gotoAndStop(5);
            }
         }
      }
      
      private function clickLeaf(param1:MouseEvent) : void
      {
         var info:NonoInfo = null;
         var r:uint = 0;
         var evt:MouseEvent = param1;
         if(Boolean(MainManager.actorModel.nono))
         {
            this._leaf.buttonMode = false;
            this._leaf.removeEventListener(MouseEvent.CLICK,this.clickLeaf);
            info = NonoManager.info;
            if(info.superNono)
            {
               r = Math.floor(Math.random() * 4) + 1;
               this._leaf.gotoAndStop(r);
               setTimeout(this.changeLeafStatus,1200,r);
            }
            else
            {
               DynamicNpcTipDialog.show("只有超能NoNo才能唤醒这片奇异豌豆叶的智能哦，快为你的NoNo充能，让它成为超能NoNo吧！",function():void
               {
                  var r:VipSession = new VipSession();
                  r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
                  {
                  });
                  r.getSession();
               },NpcTipDialog.NONO);
            }
         }
         else
         {
            NpcTipDialog.show("(≧▽≦)/嘿嘿，快带上你的超能NoNo，这是片有智能的叶子哟！",null,NpcTipDialog.NONO);
         }
      }
      
      private function changeLeafStatus(param1:uint) : void
      {
         var r:uint = param1;
         switch(r)
         {
            case 1:
               this._leaf.buttonMode = true;
               this._leaf.addEventListener(MouseEvent.CLICK,this.clickLeaf);
               return;
            case 2:
               NpcTipDialog.show("我只是一片豌豆叶子，你对我有什么期待呢？没有，我真的什么都没有，去找那些豆荚吧！",function():void
               {
                  _leaf.buttonMode = true;
                  _leaf.addEventListener(MouseEvent.CLICK,clickLeaf);
               },NpcTipDialog.LEAF);
               return;
            case 3:
               NpcTipDialog.show("疼……疼疼疼……\r    别点了，让我这么点你试试，疼死了，还让不让叶子好好光合作用了！",function():void
               {
                  _leaf.buttonMode = true;
                  _leaf.addEventListener(MouseEvent.CLICK,clickLeaf);
               },NpcTipDialog.LEAF);
               return;
            case 4:
               NpcTipDialog.show("切……看来你是有内幕的，行了行了，给你还不行么，拿去吧，砸我斜对面那朵难看的豌豆花，它会把你想要的给你的。",function():void
               {
                  _leaf.buttonMode = true;
                  _leaf.addEventListener(MouseEvent.CLICK,clickLeaf);
                  ItemAction.buyItem(600002,false,1);
               },NpcTipDialog.LEAF);
         }
      }
      
      override public function destroy() : void
      {
         this.star.destroy();
         this.star = null;
         if(Boolean(MainManager.actorModel.nono))
         {
            MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
         }
         this._time.stop();
         this._time.removeEventListener(TimerEvent.TIMER,this.timerEnterHandler);
         this.removeAdd();
         this._time = null;
         this._bao_0 = null;
         this._btn_0 = null;
         this._btn_1 = null;
         this._b_0 = null;
         this._b_1 = null;
         this._bao_1 = null;
         this._nono_mc = null;
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimatEnd);
      }
   }
}

