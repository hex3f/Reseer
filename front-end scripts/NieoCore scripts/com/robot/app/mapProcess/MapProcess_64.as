package com.robot.app.mapProcess
{
   import com.robot.app.energy.ore.*;
   import com.robot.app.ogre.*;
   import com.robot.app.petUpdate.*;
   import com.robot.app.toolBar.*;
   import com.robot.core.*;
   import com.robot.core.aimat.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.pet.*;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.npc.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_64 extends BaseMapProcess
   {
      
      private var showLackeysArr:Array = [];
      
      private var timer:Timer;
      
      private var timerBoss:Timer;
      
      private var dayOre:DayOreCount;
      
      private var typeArr:Array = [2056,2057];
      
      private var dayCount:int = 0;
      
      private var index:int = 0;
      
      private var effectMC:MovieClip;
      
      private var _isShow:Boolean;
      
      private var currentHitMC:MovieClip;
      
      private var hitCount:uint = 0;
      
      private var bloodBar:MovieClip;
      
      public function MapProcess_64()
      {
         super();
         OgreController.isShow = false;
      }
      
      private function getAwardCount(param1:int = 0) : void
      {
         if(Boolean(this.dayOre))
         {
            this.dayOre = null;
         }
         this.dayOre = new DayOreCount();
         this.dayOre.addEventListener(DayOreCount.countOK,this.getCount);
         this.dayOre.sendToServer(this.typeArr[param1]);
      }
      
      private function getCount(param1:Event) : void
      {
         this.dayOre.removeEventListener(DayOreCount.countOK,this.getCount);
         this.dayCount += DayOreCount.oreCount;
         if(this.index == 1)
         {
            this.showAwardMessage(this.dayCount);
            return;
         }
         ++this.index;
         this.getAwardCount(this.index);
      }
      
      private function showAwardMessage(param1:int) : void
      {
         this.index = 0;
         this.dayCount = 0;
         if(param1 > 5)
         {
            NpcDialog.show(NPC.SUPERNONO,["#2我不希望主人过多的去开采能源哦！我们明天再来嘛~好不好嘛！#6"],["恩！恩！你说的有道理哦！"]);
         }
         else if(param1 == 5)
         {
            NpcDialog.show(NPC.SUPERNONO,["帅！帅！帅！气井里竟然会有这么多矿石哦！#6我们明天再来看看吧！哈哈#1"],["我们明天再来看看"]);
         }
         else
         {
            this.effectMC.visible = true;
            this.effectMC.gotoAndPlay(2);
            MainManager.actorModel.hideNono();
            this.effectMC.addEventListener(Event.ENTER_FRAME,this.onFrameHandler);
         }
      }
      
      private function onFrameHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         DisplayUtil.FillColor(this.effectMC["nono_mc"],MainManager.actorInfo.nonoColor);
         if(this.effectMC.currentFrame == this.effectMC.totalFrames)
         {
            this.effectMC.removeEventListener(Event.ENTER_FRAME,this.onFrameHandler);
            this.effectMC.visible = false;
            this.effectMC.gotoAndStop(1);
            _loc2_ = Math.round(Math.random() * 10);
            if(_loc2_ <= 5)
            {
               SocketConnection.send(CommandID.TALK_CATE,this.typeArr[0]);
            }
            else
            {
               SocketConnection.send(CommandID.TALK_CATE,this.typeArr[1]);
            }
         }
      }
      
      private function onSuccess(param1:SocketEvent) : void
      {
         var _loc2_:CateInfo = null;
         var _loc3_:String = null;
         var _loc4_:DayTalkInfo = param1.data as DayTalkInfo;
         if(_loc4_.outList.length > 0)
         {
            if(_loc4_.outList.length == 1)
            {
               _loc2_ = _loc4_.outList[0];
               _loc3_ = "超能NoNo帅！超能NoNo有智慧！我就是那个最最超能的超能NoNo咯！哈哈！铛铛0xff0000" + _loc2_.count + "0xffffff块0xff0000" + ItemXMLInfo.getName(_loc2_.id) + "0xffffff矿石到手咯！主人你快看看，我厉害不？";
               NpcDialog.show(NPC.SUPERNONO,[_loc3_],["哇哦！很棒耶！我们再来一次吧！"]);
               MainManager.actorModel.showNono(NonoManager.info,MainManager.actorInfo.actionType);
               if(_loc2_ == null)
               {
               }
            }
         }
      }
      
      override protected function init() : void
      {
         this.effectMC = conLevel["effect_mc"];
         this.effectMC.visible = false;
         this.timer = new Timer(5000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this.timer.start();
         this.timerBoss = new Timer(10000);
         this.timerBoss.addEventListener(TimerEvent.TIMER,this.onTimerBossHandler);
         this.timerBoss.start();
         AimatController.addEventListener(AimatEvent.PLAY_END,this.onAimatHandler);
         SocketConnection.addCmdListener(CommandID.NOTE_UPDATE_PROP,this.onUpdateProp);
         SocketConnection.addCmdListener(CommandID.NONO_IS_INFO,this.onGetExpHandler);
         SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onSuccess);
      }
      
      private function onGetExpHandler(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:int = int(_loc2_.readUnsignedInt());
         this.showAwardMessageExp(_loc3_);
      }
      
      private function onUpdateProp(param1:SocketEvent) : void
      {
         this._isShow = true;
      }
      
      private function showUp() : void
      {
         if(this._isShow)
         {
            PetUpdatePropController.owner.show(true);
            this._isShow = false;
         }
      }
      
      private function onClickHandler() : Boolean
      {
         if(Boolean(MainManager.actorModel.pet))
         {
            if(PetXMLInfo.getTypeCN(MainManager.actorModel.pet.info.petID) == "地面")
            {
               return true;
            }
            if(MainManager.actorInfo.superNono)
            {
               NpcDialog.show(NPC.SUPERNONO,["主人你的0xff0000地面系精灵0xffffff呢？快把它带在身边吧！没它的帮忙我们可没办法用头部射击打到爪牙呢！"],["确定"],[function():void
               {
               }]);
            }
            else
            {
               NpcDialog.show(NPC.NONO,["哎呀！你还没有带上0xff0000地面系精灵0xffffff呢！没有它的帮忙，我们无法用头部射击效果打到它呀！"],["我这就带上我的地面系精灵一起来作战！"],[function():void
               {
               }]);
            }
            return false;
         }
         if(MainManager.actorInfo.superNono)
         {
            NpcDialog.show(NPC.SUPERNONO,["主人你的0xff0000地面系精灵0xffffff呢？快把它带在身边吧！没它的帮忙我们可没办法用头部射击打到爪牙呢！"],["确定"],[function():void
            {
            }]);
         }
         else
         {
            NpcDialog.show(NPC.NONO,["哎呀！你还没有带上0xff0000地面系精灵0xffffff呢！没有它的帮忙，我们无法用头部射击效果打到它呀！"],["我这就带上我的地面系精灵一起来作战！"],[function():void
            {
            }]);
         }
         return false;
      }
      
      private function onBossClickHandler() : Boolean
      {
         return this.onClickHandler();
      }
      
      private function controlBloodBar(param1:MovieClip, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = param1.currentFrame;
         if(MainManager.actorInfo.superNono)
         {
            if(Boolean(param2))
            {
               _loc4_ = 5;
            }
            else
            {
               _loc4_ = 8;
            }
         }
         else
         {
            _loc4_ = 4;
         }
         param1.gotoAndStop(_loc3_ + _loc4_ - 1);
         if(_loc3_ < _loc4_)
         {
            DisplayUtil.removeForParent(param1);
         }
      }
      
      private function onAimatHandler(param1:AimatEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         if(MainManager.actorID != param1.info.userID)
         {
            return;
         }
         var _loc6_:Point = param1.info.endPos;
         var _loc7_:uint = uint(param1.info.id);
         if(Boolean(this.currentHitMC))
         {
            if(this.currentHitMC.hitTestPoint(_loc6_.x,_loc6_.y))
            {
               ToolBarController.closePetBag(false);
               ++this.hitCount;
               this.currentHitMC["mc"].gotoAndPlay(2);
               if(this.currentHitMC.name.indexOf("boss") != -1)
               {
                  this.controlBloodBar(this.bloodBar,1);
                  if(this.hitCount >= 8)
                  {
                     SocketConnection.send(CommandID.NONO_IS_INFO,2);
                     ToolBarController.closePetBag(true);
                     this.currentHitMC.gotoAndStop(3);
                     this.currentHitMC = null;
                     this.hitCount = 0;
                     DisplayUtil.removeForParent(this.bloodBar);
                     this.bloodBar = null;
                     OgreController.isShow = true;
                  }
               }
               else
               {
                  this.controlBloodBar(this.bloodBar,0);
                  if(MainManager.actorInfo.superNono)
                  {
                     if(this.hitCount >= 5)
                     {
                        SocketConnection.send(CommandID.NONO_IS_INFO,2);
                        ToolBarController.closePetBag(true);
                        this.currentHitMC.gotoAndStop(3);
                        this.currentHitMC = null;
                        this.hitCount = 0;
                        DisplayUtil.removeForParent(this.bloodBar);
                        this.bloodBar = null;
                        if(!this.timerBoss.running)
                        {
                           this.timerBoss.start();
                        }
                     }
                  }
                  else if(this.hitCount >= 10)
                  {
                     SocketConnection.send(CommandID.NONO_IS_INFO,2);
                     ToolBarController.closePetBag(true);
                     this.currentHitMC.gotoAndStop(3);
                     this.currentHitMC = null;
                     this.hitCount = 0;
                     DisplayUtil.removeForParent(this.bloodBar);
                     this.bloodBar = null;
                     if(!this.timerBoss.running)
                     {
                        this.timerBoss.start();
                     }
                  }
               }
            }
         }
         else
         {
            _loc2_ = this.showLackeysArr.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(Boolean(this.showLackeysArr[_loc3_]["mc"].hitTestPoint(_loc6_.x,_loc6_.y)))
               {
                  if(this.onClickHandler())
                  {
                     this.bloodBar = MapLibManager.getMovieClip("BloodBar");
                     ToolBarController.closePetBag(false);
                     this.controlBloodBar(this.bloodBar,0);
                     this.currentHitMC = this.showLackeysArr[_loc3_];
                     _loc4_ = this.currentHitMC.localToGlobal(new Point(0,0));
                     if(_loc4_.x > 600)
                     {
                        this.bloodBar.x = _loc4_.x - this.bloodBar.width / 2;
                     }
                     else
                     {
                        this.bloodBar.x = _loc4_.x;
                     }
                     this.bloodBar.y = _loc4_.y;
                     conLevel.addChild(this.bloodBar);
                     this.timer.stop();
                     this.timerBoss.stop();
                     this.hideLackeys();
                     this.hideBossLackeys();
                     ++this.hitCount;
                     this.currentHitMC.gotoAndStop(4);
                  }
                  break;
               }
               _loc3_++;
            }
            if(this.currentHitMC == null)
            {
               if(Boolean(conLevel["lackey_boss"]["bossmc"]))
               {
                  if(Boolean(conLevel["lackey_boss"]["bossmc"].hitTestPoint(_loc6_.x,_loc6_.y)))
                  {
                     if(this.onBossClickHandler())
                     {
                        this.bloodBar = MapLibManager.getMovieClip("BloodBar");
                        ToolBarController.closePetBag(false);
                        this.controlBloodBar(this.bloodBar,1);
                        this.currentHitMC = conLevel["lackey_boss"];
                        _loc5_ = this.currentHitMC.localToGlobal(new Point(0,0));
                        this.bloodBar.x = _loc5_.x;
                        this.bloodBar.y = _loc5_.y;
                        conLevel.addChild(this.bloodBar);
                        this.timer.stop();
                        this.timerBoss.stop();
                        this.hideLackeys();
                        this.hideBossLackeys();
                        ++this.hitCount;
                        this.currentHitMC.gotoAndStop(4);
                     }
                  }
               }
            }
         }
      }
      
      private function showAwardMessageExp(param1:Number) : void
      {
         var exp:Number = param1;
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,arguments.callee);
            var _loc3_:PetInfo = param1.data as PetInfo;
            var _loc4_:String = TextFormatUtil.getRedTxt(String(exp));
            var _loc5_:String = TextFormatUtil.getRedTxt(PetXMLInfo.getName(_loc3_.id));
            if(_loc3_.level >= 100)
            {
               Alarm.show(_loc5_ + " 是100级的精灵哟，没法再获得能量长大了！");
            }
            else if(exp >= 3000)
            {
               Alarm.show("嘿咻！嘿咻！不错啊！" + _loc5_ + " 经过了这场战斗，增长了" + _loc4_ + "\'点经验。",showUp);
            }
            else if(exp < 3000 && exp > 2000)
            {
               Alarm.show("哇塞！！！" + _loc5_ + "增长了" + _loc4_ + "点经验。 ",showUp);
            }
            else if(exp <= 2000 && exp > 1000)
            {
               Alarm.show("“嘿！这场战斗带来的收获可不小啊！" + _loc5_ + "你已经获得了" + _loc4_ + "点经验。",showUp);
            }
            else if(exp > 0 && exp <= 1000)
            {
               Alarm.show("哦哒哒哒哒！我看你还敢出来！" + _loc5_ + "增长了" + _loc4_ + "点经验。",showUp);
            }
            else
            {
               Alarm.show(MainManager.actorInfo.nick + "我相信在我们不间断的努力下！我们都会变得更强！");
            }
            timer.start();
            timerBoss.start();
         });
         SocketConnection.send(CommandID.GET_PET_INFO,MainManager.actorModel.pet.info.catchTime);
      }
      
      private function onTimerBossHandler(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         this.showBossLackeys();
         setTimeout(function():void
         {
            hideBossLackeys();
         },2000);
      }
      
      private function onTimerHandler(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         this.showLackeys();
         setTimeout(function():void
         {
            hideLackeys();
         },3000);
      }
      
      override public function destroy() : void
      {
         ToolBarController.closePetBag(true);
         OgreController.isShow = true;
         this.hideLackeys();
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimerHandler);
         this.timer = null;
         this.timerBoss.stop();
         this.timerBoss.removeEventListener(TimerEvent.TIMER,this.onTimerBossHandler);
         this.timerBoss = null;
         AimatController.removeEventListener(AimatEvent.PLAY_END,this.onAimatHandler);
         this.hitCount = 0;
         this.currentHitMC = null;
         SocketConnection.removeCmdListener(CommandID.NOTE_UPDATE_PROP,this.onUpdateProp);
         SocketConnection.removeCmdListener(CommandID.NONO_IS_INFO,this.onGetExpHandler);
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onSuccess);
         if(Boolean(this.bloodBar))
         {
            DisplayUtil.removeForParent(this.bloodBar);
         }
      }
      
      private function showBossLackeys() : void
      {
         conLevel["lackey_boss"].gotoAndStop(2);
      }
      
      private function hideBossLackeys() : void
      {
         if(conLevel["lackey_boss"].currentFrame == 2)
         {
            conLevel["lackey_boss"].gotoAndStop(3);
         }
      }
      
      private function showLackeys() : void
      {
         var seedInt:Number = NaN;
         var seedInt1:Number = NaN;
         var lackeys:MovieClip = null;
         var lackeys1:MovieClip = null;
         lackeys1 = null;
         this.hideLackeys();
         seedInt = Number(NumberUtils.random(1,4));
         seedInt1 = Number(NumberUtils.random(1,4));
         if(seedInt == seedInt1)
         {
            seedInt1++;
         }
         lackeys = conLevel.getChildByName("lackey_" + seedInt) as MovieClip;
         lackeys1 = conLevel.getChildByName("lackey_" + seedInt1) as MovieClip;
         if(Boolean(lackeys))
         {
            lackeys.gotoAndStop(2);
            this.showLackeysArr.push(lackeys);
         }
         setTimeout(function():void
         {
            if(Boolean(lackeys1))
            {
               lackeys1.gotoAndStop(2);
               showLackeysArr.push(lackeys1);
            }
         },1200);
      }
      
      private function hideLackeys() : void
      {
         var _loc2_:uint = 0;
         var _loc1_:uint = this.showLackeysArr.length;
         while(_loc2_ < _loc1_)
         {
            this.showLackeysArr[_loc2_].gotoAndStop(3);
            _loc2_++;
         }
         this.showLackeysArr = [];
      }
      
      public function playNonoEffect() : void
      {
         if(MainManager.actorInfo.superNono)
         {
            if(Boolean(MainManager.actorModel.nono))
            {
               NpcDialog.show(NPC.SUPERNONO,["哇哦！！！云雾气井！闻名不如见面呀！哇哈哈！我们这就来一看究竟咯！！听说这里还藏有很多种矿石呐！#8"],["云雾气井！我们来咯！"],[function():void
               {
                  getAwardCount();
               }]);
            }
            else
            {
               NpcDialog.show(NPC.SUPERNONO,["哎呀呀！！！快召唤你的超能NoNo进入一起来体验云雾气井的神奇吧！哇哦！#6"],["确定"],[function():void
               {
               }]);
            }
         }
         else
         {
            NpcDialog.show(NPC.SUPERNONO,["要知道这里喷出来的气体温度可是很高的！再聪明的NoNo也没辙啊！快开通0xff0000超能NoNo0xffffff，只有它才能带你一同体验被气流冲击的感觉！"],["我这就去开通超能NoNo","好吧！那我再去看看其他地方……"],[function():void
            {
               MapManager.changeMap(107);
            }]);
         }
      }
   }
}

