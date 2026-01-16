package com.robot.app.mapProcess
{
   import com.robot.app.control.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.PetModel;
   import com.robot.core.net.*;
   import com.robot.core.newloader.*;
   import com.robot.core.temp.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.events.DynamicEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_316 extends BaseMapProcess
   {
      
      private var lineBeltMC:MovieClip;
      
      private var spriteTransferMC:MovieClip;
      
      private var spriteContainerMC:MovieClip;
      
      private var petType:String;
      
      private var comdType:uint = 3;
      
      private var trainingMC_0:MovieClip;
      
      private var trainingMC_1:MovieClip;
      
      private var trainingMC_2:MovieClip;
      
      private var trainingMC_3:MovieClip;
      
      private var trainingMcArr:Array = [];
      
      private var pao_mc:SimpleButton;
      
      private var petShowInfo:PetShowInfo;
      
      private var _showMc:MovieClip;
      
      private var _showMc1:MovieClip;
      
      private var _leiyi:SimpleButton;
      
      private var _panel:MovieClip;
      
      private var petT:String;
      
      private var loader:MCLoader;
      
      private var curDisplayObj:DisplayObject;
      
      public function MapProcess_316()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:MovieClip = null;
         this.lineBeltMC = conLevel["lineBeltMC"];
         this.lineBeltMC.buttonMode = true;
         this._leiyi = conLevel["leiyi_mc"];
         this._panel = btnLevel["panel_mc"];
         this._panel.visible = false;
         this._leiyi.addEventListener(MouseEvent.CLICK,this.leiyiClickHandler);
         ToolTipManager.add(this._leiyi,"拜伦号精灵舱");
         ToolTipManager.add(this.lineBeltMC,"精灵养成装置");
         this.spriteTransferMC = conLevel["spriteTransferMC"];
         this.spriteContainerMC = this.spriteTransferMC["spriteContainerMC"];
         this.spriteTransferMC.gotoAndStop(1);
         this.trainingMC_0 = conLevel["trainingMC_0"];
         this.trainingMC_1 = conLevel["trainingMC_1"];
         this.trainingMC_2 = conLevel["trainingMC_2"];
         this.trainingMC_3 = conLevel["trainingMC_3"];
         this.pao_mc = conLevel["paopao_mc"];
         ToolTipManager.add(this.pao_mc,"精灵泡泡机");
         this.pao_mc.addEventListener(MouseEvent.CLICK,this.paoclickHandler);
         this.trainingMcArr = [this.trainingMC_0,this.trainingMC_1,this.trainingMC_2,this.trainingMC_3];
         for each(_loc1_ in this.trainingMcArr)
         {
            _loc1_.gotoAndStop(1);
         }
      }
      
      public function onLeaveHandler() : void
      {
         Alert.show("你确定要离开这里吗?",function():void
         {
            MapManager.changeMap(315);
         });
      }
      
      private function leiyiClickHandler(param1:MouseEvent) : void
      {
         var clickokBtn:Function = null;
         var e:MouseEvent = param1;
         clickokBtn = null;
         clickokBtn = function(param1:MouseEvent):void
         {
            _panel.visible = false;
            _panel["ok_btn"].removeEventListener(MouseEvent.CLICK,clickokBtn);
         };
         this._panel.visible = true;
         this._panel["ok_btn"].addEventListener(MouseEvent.CLICK,clickokBtn);
      }
      
      private function paoclickHandler(param1:MouseEvent) : void
      {
         if(!MainManager.actorModel.nono)
         {
            Alarm.show("精灵泡泡机能量不足，只有带上超能NoNo，用的超级能量才能维持它的运转。");
         }
         else if(Boolean(MainManager.actorModel.pet))
         {
            this.petT = PetXMLInfo.getTypeCN(MainManager.actorModel.pet.info.petID);
            this.showGame();
         }
         else
         {
            Alarm.show("精灵泡泡机是先进的精灵学习机，你要带着精灵来哦！");
         }
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         this._showMc1 = param1 as MovieClip;
         if(Boolean(this._showMc1))
         {
            this._showMc1.gotoAndStop(Direction.UP);
            this.showGame();
         }
      }
      
      override public function destroy() : void
      {
         this.lineBeltMC = null;
         this.spriteTransferMC = null;
         this.spriteContainerMC = null;
         this.trainingMC_0 = null;
         this.trainingMC_1 = null;
         this.trainingMC_2 = null;
         this.trainingMC_3 = null;
         this.trainingMcArr = null;
         this.pao_mc = null;
         this.petShowInfo = null;
         this._showMc = null;
         this._showMc1 = null;
         this._leiyi = null;
         this._panel = null;
         EventManager.removeEventListener("Training_Pet_Sucess",this.petTrainingSucess);
         EventManager.removeEventListener("Training_Pet_False",this.petTrainingFalse);
      }
      
      private function addEvent() : void
      {
         EventManager.addEventListener("Training_Pet_Sucess",this.petTrainingSucess);
         EventManager.addEventListener("Training_Pet_False",this.petTrainingFalse);
         SocketConnection.addCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
      }
      
      private function removeEvent() : void
      {
         EventManager.removeEventListener("Training_Pet_Sucess",this.petTrainingSucess);
         EventManager.removeEventListener("Training_Pet_False",this.petTrainingFalse);
      }
      
      public function clickLineBelt() : void
      {
         var _loc1_:PetShowInfo = null;
         if(MainManager.actorModel.nono == null)
         {
            NpcTipDialog.show("带上你的NoNo才能给精灵进行训练噢!",null,NpcTipDialog.SHAWN);
            return;
         }
         var _loc2_:PetModel = MainManager.actorModel.pet;
         if(Boolean(_loc2_))
         {
            _loc1_ = MainManager.actorModel.pet.info;
            this.petShowInfo = _loc1_;
            this.petType = PetXMLInfo.getType(_loc1_.petID);
            MainManager.actorModel.pet.visible = false;
            ResourceManager.getResource(ClientConfig.getPetSwfPath(_loc2_.info.petID),this.onShowComplete1,"pet");
         }
         else
         {
            NpcTipDialog.show("带上你的精灵才能给它进行训练噢!",null,NpcTipDialog.DOCTOR);
         }
      }
      
      private function onShowComplete1(param1:DisplayObject) : void
      {
         this._showMc = param1 as MovieClip;
         if(Boolean(this._showMc))
         {
            this._showMc.gotoAndStop(Direction.LEFT_DOWN);
            this.spriteContainerMC.addChild(this._showMc);
            this._showMc.x = this._showMc.width / 2 + 5;
            this._showMc.y = this._showMc.height;
            this.spriteTransferMC.gotoAndPlay(2);
            this.spriteTransferMC.addEventListener(Event.ENTER_FRAME,this.chosFoodTra);
            this.lineBeltMC.mouseEnabled = false;
            this.addEvent();
         }
      }
      
      public function showGame() : void
      {
         SocketConnection.addCmdListener(CommandID.JOIN_GAME,this.onJoinGame);
         SocketConnection.send(CommandID.JOIN_GAME,1);
      }
      
      private function onJoinGame(param1:SocketEvent) : void
      {
         MapManager.destroy();
         SocketConnection.removeCmdListener(CommandID.JOIN_GAME,this.onJoinGame);
         this.loader = new MCLoader("resource/Games/PaoPaoGame.swf",LevelManager.topLevel,1,"正在加载游戏");
         this.loader.addEventListener(MCLoadEvent.SUCCESS,this.onLoadDLL);
         this.loader.doLoad();
      }
      
      private function onLoadDLL(param1:MCLoadEvent) : void
      {
         MainManager.getStage().frameRate = 40;
         this.loader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadDLL);
         this.loader = null;
         LevelManager.topLevel.addChild(param1.getContent());
         param1.getContent().addEventListener("gamelost",this.onGameOver);
         param1.getContent().addEventListener("gameclose",this.onGameOver);
         param1.getContent().addEventListener("gamewin",this.onGameOver);
         this.curDisplayObj = param1.getContent();
         var _loc2_:* = this.curDisplayObj as Sprite;
         _loc2_.addMc(this.petT);
      }
      
      private function onGameOver(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         MainManager.getStage().frameRate = 24;
         var _loc3_:* = param1.target as Sprite;
         if(_loc3_._bili < 1)
         {
            _loc2_ = 1;
         }
         else
         {
            _loc2_ = Number(_loc3_._bili);
         }
         var _loc4_:int = int(int((_loc2_ - 1) / 2 * 10) * 10);
         var _loc5_:int = int(_loc4_ * 10);
         MapManager.refMap();
         this.curDisplayObj.removeEventListener("gamelost",this.onGameOver);
         this.curDisplayObj.removeEventListener("gameclose",this.onGameOver);
         this.curDisplayObj.removeEventListener("gamewin",this.onGameOver);
         this.curDisplayObj = null;
         SocketConnection.send(CommandID.GAME_OVER,_loc4_,_loc4_);
      }
      
      private function chosFoodTra(param1:Event) : void
      {
         var timer_0:Timer = null;
         var evt:Event = param1;
         timer_0 = null;
         if(this.spriteTransferMC.currentLabel == "one")
         {
            this.spriteTransferMC.removeEventListener(Event.ENTER_FRAME,this.chosFoodTra);
            this.spriteTransferMC.gotoAndStop("one");
            this.trainingMC_0.gotoAndStop(2);
            timer_0 = new Timer(2000,1);
            timer_0.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               timer_0.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer_0.stop();
               timer_0 = null;
               ChosSpriteFoodController.showPanel();
            });
            timer_0.start();
         }
      }
      
      private function spritePhyTra(param1:Event) : void
      {
         var timer_1:Timer = null;
         var evt:Event = param1;
         timer_1 = null;
         if(this.spriteTransferMC.currentLabel == "two")
         {
            this.spriteTransferMC.removeEventListener(Event.ENTER_FRAME,this.spritePhyTra);
            this.spriteTransferMC.gotoAndStop("two");
            this.trainingMC_1.gotoAndStop(2);
            this.trainingMC_0.gotoAndStop(1);
            timer_1 = new Timer(2000,1);
            timer_1.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               timer_1.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer_1.stop();
               timer_1 = null;
               SpritePhyTraController.showPanel();
            });
            timer_1.start();
         }
      }
      
      private function spriteRaceTra(param1:Event) : void
      {
         var timer_2:Timer = null;
         var evt:Event = param1;
         timer_2 = null;
         if(this.spriteTransferMC.currentLabel == "three")
         {
            this.spriteTransferMC.removeEventListener(Event.ENTER_FRAME,this.spriteRaceTra);
            this.spriteTransferMC.gotoAndStop("three");
            this.trainingMC_2.gotoAndStop(2);
            this.trainingMC_1.gotoAndStop(1);
            timer_2 = new Timer(2000,1);
            timer_2.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               timer_2.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer_2.stop();
               timer_2 = null;
               SpriteRaceTraController.showPanel();
            });
            timer_2.start();
         }
      }
      
      private function spriteElecTra(param1:Event) : void
      {
         var timer_3:Timer = null;
         var evt:Event = param1;
         timer_3 = null;
         if(this.spriteTransferMC.currentLabel == "four")
         {
            this.spriteTransferMC.removeEventListener(Event.ENTER_FRAME,this.spriteElecTra);
            this.spriteTransferMC.gotoAndStop("four");
            this.trainingMC_3.gotoAndStop(2);
            this.trainingMC_2.gotoAndStop(1);
            timer_3 = new Timer(2000,1);
            timer_3.addEventListener(TimerEvent.TIMER,function(param1:TimerEvent):void
            {
               timer_3.removeEventListener(TimerEvent.TIMER,arguments.callee);
               timer_3.stop();
               timer_3 = null;
               SpriteElecTraController.showPanel();
            });
            timer_3.start();
         }
      }
      
      private function petTrainingSucess(param1:DynamicEvent) : void
      {
         var _loc2_:String = null;
         this.spriteTransferMC.gotoAndPlay(this.spriteTransferMC.currentFrame + 1);
         var _loc3_:String = param1.paramObject as String;
         var _loc4_:String = NpcTipDialog.NONO_2;
         if(MainManager.actorInfo.superNono)
         {
            _loc4_ = NpcTipDialog.NONO;
         }
         switch(_loc3_)
         {
            case "game_0":
               this.spriteTransferMC.addEventListener(Event.ENTER_FRAME,this.spritePhyTra);
               return;
            case "game_1":
               if(!MainManager.actorInfo.superNono)
               {
                  _loc2_ = "精灵养成机能量不足，需要超能NoNo的超级能量才能维持它的后续运转。";
                  this.comdType = 4;
                  NpcTipDialog.show(_loc2_,this.returnPetStatus,NpcTipDialog.NONO_2,0,this.returnPetStatus);
                  return;
               }
               this.spriteTransferMC.addEventListener(Event.ENTER_FRAME,this.spriteRaceTra);
               return;
               break;
            case "game_2":
               this.spriteTransferMC.addEventListener(Event.ENTER_FRAME,this.spriteElecTra);
               return;
            case "game_3":
               this.comdType = 6;
               this.returnPetStatus();
         }
      }
      
      private function petTrainingFalse(param1:DynamicEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = param1.paramObject as String;
         var _loc9_:String = NpcTipDialog.NONO_2;
         if(MainManager.actorInfo.superNono)
         {
            _loc9_ = NpcTipDialog.NONO;
         }
         for each(_loc2_ in this.trainingMcArr)
         {
            _loc2_.gotoAndStop(1);
         }
         switch(_loc8_)
         {
            case "game_0":
               _loc3_ = "主人主人，你需要对精灵有更多的了解哦！每种不同属性的精灵喜欢不同的食物呢！";
               this.comdType = 0;
               NpcTipDialog.show(_loc3_,this.returnPetStatus,_loc9_,0,this.returnPetStatus);
               return;
            case "game_1":
               _loc4_ = "精灵们还需要更多的锻炼啊，继续努力吧！";
               this.comdType = 3;
               NpcTipDialog.show(_loc4_,this.returnPetStatus,_loc9_,0,this.returnPetStatus);
               return;
            case "game_2":
               _loc5_ = "精灵们还需要更多的锻炼啊，继续努力吧！";
               this.comdType = 4;
               NpcTipDialog.show(_loc5_,this.returnPetStatus,_loc9_,0,this.returnPetStatus);
               return;
            case "game_3":
               SocketConnection.send(CommandID.PRIZE_OF_ATRESIASPACE,5);
               return;
            case "small":
               _loc6_ = "这样不能激发精灵的最佳体能哦，再试试看吧！";
               this.comdType = 5;
               NpcTipDialog.show(_loc6_,this.returnPetStatus,_loc9_,0,this.returnPetStatus);
               return;
            case "big":
               _loc7_ = "那么强的电力会让精灵们受伤呢，要疼爱精灵们哦！";
               this.comdType = 5;
               NpcTipDialog.show(_loc7_,this.returnPetStatus,_loc9_,0,this.returnPetStatus);
         }
      }
      
      private function returnPetStatus() : void
      {
         this.lineBeltMC.mouseEnabled = true;
         MainManager.actorModel.pet.visible = true;
         this.spriteTransferMC.gotoAndStop(1);
         DisplayUtil.removeForParent(this._showMc);
         this._showMc = null;
         if(this.comdType != 0)
         {
            SocketConnection.send(CommandID.PRIZE_OF_ATRESIASPACE,this.comdType);
         }
      }
      
      private function getPirze(param1:SocketEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         SocketConnection.removeCmdListener(CommandID.PRIZE_OF_ATRESIASPACE,this.getPirze);
         var _loc7_:AresiaSpacePrize = param1.data as AresiaSpacePrize;
         var _loc8_:Array = _loc7_.monBallList;
         for each(_loc2_ in _loc8_)
         {
            _loc3_ = uint(_loc2_.itemID);
            _loc4_ = uint(_loc2_.itemCnt);
            _loc5_ = ItemXMLInfo.getName(_loc3_);
            _loc6_ = _loc4_ + "个<font color=\'#FF0000\'>" + _loc5_ + "</font>已经放入了你的储存箱！";
            if(_loc4_ != 0)
            {
               LevelManager.tipLevel.addChild(ItemInBagAlert.show(_loc3_,_loc6_));
            }
         }
      }
   }
}

