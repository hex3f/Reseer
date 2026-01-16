package com.robot.petFightModule.control
{
   import com.robot.app.automaticFight.*;
   import com.robot.core.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.fightInfo.attack.*;
   import com.robot.core.info.pet.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.control.petItemCon.*;
   import com.robot.petFightModule.data.*;
   import com.robot.petFightModule.mode.*;
   import flash.display.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.filters.*;
   import flash.media.Sound;
   import flash.text.TextField;
   import flash.utils.*;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PetFightController extends EventDispatcher
   {
      
      private static var sound:Sound;
      
      private var isReciveUseSkillCmd:Boolean = false;
      
      private var isPlaySkillMovie:Boolean = false;
      
      public var isSysError:Boolean = false;
      
      public var isDraw:Boolean = false;
      
      private var queue:Array = [];
      
      private var petContainer:Sprite;
      
      private var overData:FightOverInfo;
      
      private var isUsingItem:Boolean = false;
      
      public var isCatch:Boolean = false;
      
      public var isNpcEscape:Boolean = false;
      
      public var isEscape:Boolean = false;
      
      private var _mainPanel:Sprite;
      
      public var isOvertime:Boolean = false;
      
      private var hashMap:HashMap;
      
      public var isPlayerLost:Boolean = false;
      
      public var alarmSprite:Sprite;
      
      private var isFightOver:Boolean = false;
      
      private var npcIsdied:Boolean = false;
      
      public var roundTime:uint = 0;
      
      private var round:TextField;
      
      public function PetFightController()
      {
         super();
         this.hashMap = new HashMap();
         this.createMainUI();
         SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL,this.onUseSkill);
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,this.onFightOver);
         SocketConnection.addCmdListener(CommandID.CHANGE_PET,this.onChangePet);
         SocketConnection.addCmdListener(CommandID.ESCAPE_FIGHT,this.onEscapeFight);
         SocketConnection.addCmdListener(CommandID.USE_PET_ITEM,this.onUsePetItem);
         SocketConnection.addCmdListener(CommandID.CATCH_MONSTER,this.onCatchMonster);
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,onGetPetInfo);
         EventManager.addEventListener(PetFightEvent.PET_HAS_EXIST,this.hasExistHandler);
         EventManager.addEventListener(PetFightEvent.ON_USE_PET_ITEM,this.onUsePetItemOver);
      }
      
      private static function onGetPetInfo(param1:SocketEvent) : void
      {
         var _loc2_:PetInfo = param1.data as PetInfo;
         PetManager.add(_loc2_);
      }
      
      public function destroy() : void
      {
         var _loc1_:BaseFighterMode = null;
         SocketConnection.removeCmdListener(CommandID.NOTE_USE_SKILL,this.onUseSkill);
         SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,this.onFightOver);
         SocketConnection.removeCmdListener(CommandID.CHANGE_PET,this.onChangePet);
         SocketConnection.removeCmdListener(CommandID.ESCAPE_FIGHT,this.onEscapeFight);
         SocketConnection.removeCmdListener(CommandID.USE_PET_ITEM,this.onUsePetItem);
         SocketConnection.removeCmdListener(CommandID.CATCH_MONSTER,this.onCatchMonster);
         SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,onGetPetInfo);
         EventManager.removeEventListener(PetFightEvent.PET_HAS_EXIST,this.hasExistHandler);
         EventManager.removeEventListener(PetFightEvent.ON_USE_PET_ITEM,this.onUsePetItemOver);
         for each(_loc1_ in this.hashMap.getValues())
         {
            _loc1_.removeEventListener(BaseFighterMode.ATTACK_OVER,this.onAttackOver);
            _loc1_.destroy();
         }
         this.hashMap.clear();
         this.hashMap = null;
         DisplayUtil.removeAllChild(this._mainPanel);
         DisplayUtil.removeForParent(this._mainPanel);
         this._mainPanel = null;
         FighterModeFactory.clear();
         TimerManager.stop();
         this.petContainer = null;
      }
      
      private function onUseSkill(param1:SocketEvent) : void
      {
         if(Boolean(PetFightEntry.isCanAuto) && Boolean(AutomaticFightManager.isStart))
         {
            AutomaticFightManager.subTimes();
         }
         this.isReciveUseSkillCmd = true;
         var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
         this.queue = [];
         this.queue.push(_loc2_.firstAttackInfo);
         this.queue.push(_loc2_.secondAttackInfo);
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL_SUC_ATTACK,_loc2_));
         if(!this.isUsingItem)
         {
            this.execute();
         }
         ++this.roundTime;
         this.round.text = "当前回合:" + this.roundTime;
      }
      
      private function hasExistHandler(param1:PetFightEvent) : void
      {
         this.alarmSprite = Alarm.show("你已经有了一只同样的精灵，不能重复捕捉！");
         MainManager.getStage().addChild(this.alarmSprite);
         var _loc2_:BaseFighterMode = this.getFighterMode(MainManager.actorID);
         _loc2_.catchPet();
      }
      
      private function onUsePetItem(param1:SocketEvent) : void
      {
         this.isUsingItem = true;
         var _loc2_:UsePetItemInfo = param1.data as UsePetItemInfo;
         var _loc3_:BaseFighterMode = this.getFighterMode(_loc2_.userID);
         UsePetItemController.useItem(_loc3_,_loc2_);
      }
      
      private function onCatchMonster(param1:SocketEvent) : void
      {
         this.isUsingItem = true;
         var _loc2_:CatchPetInfo = param1.data as CatchPetInfo;
         var _loc3_:BaseFighterMode = this.getFighterMode(MainManager.actorID);
         _loc3_.catchPet(_loc2_);
      }
      
      private function onEscapeFight(param1:SocketEvent) : void
      {
         this.isEscape = true;
      }
      
      private function onChangePet(param1:SocketEvent) : void
      {
         var _loc2_:BaseFighterMode = null;
         var _loc3_:ChangePetInfo = param1.data as ChangePetInfo;
         if(_loc3_.userID == 0)
         {
            NpcChangePetData.add(_loc3_);
         }
         else
         {
            _loc2_ = this.getFighterMode(_loc3_.userID);
            _loc2_.changePet(_loc3_);
            if(_loc3_.userID == MainManager.actorID && PetFightModel.status == PetFightModel.FIGHT_WITH_NPC)
            {
               try
               {
                  this.getFighterMode(0).propView.setHpTxtVisable(_loc3_.petID);
               }
               catch(error:Error)
               {
               }
            }
         }
      }
      
      private function createMainUI() : void
      {
         this._mainPanel = new ui_mainPanel();
         this.petContainer = this._mainPanel["petContainer"];
         this.initBackground();
         this.round = this._mainPanel["round_txt"];
         this.round.text = "当前回合:" + this.roundTime;
         TimerManager.setup(this._mainPanel["time_txt"]);
         PetFightMsgManager.setup(this._mainPanel["msgMC"]);
      }
      
      private function addFightUI() : void
      {
         this.petContainer.addChild(FighterModeFactory.enemyMode.petWin);
         this.petContainer.addChild(FighterModeFactory.playerMode.petWin);
      }
      
      public function getFighterMode(param1:uint) : BaseFighterMode
      {
         return this.hashMap.getValue(param1) as BaseFighterMode;
      }
      
      public function get mainPanel() : Sprite
      {
         return this._mainPanel;
      }
      
      private function initBackground() : void
      {
         DisplayUtil.removeAllChild(this._mainPanel["bgContainer"]);
         var _loc1_:BitmapData = new BitmapData(MainManager.getStageWidth(),MainManager.getStageHeight());
         _loc1_.draw(MapManager.currentMap.root.getChildAt(0));
         var _loc2_:Bitmap = new Bitmap(_loc1_);
         var _loc3_:Array = [0.7,0.4,0.1,0,0,0.6,0.4,0.1,0,-10,0.5,0.4,0.1,0,-25,0,0,0,1,0];
         _loc2_.filters = [new ColorMatrixFilter(_loc3_),new BlurFilter(4,4,3)];
         this._mainPanel["bgContainer"].addChild(_loc2_);
         MapManager.destroy();
      }
      
      private function onFightOver(param1:SocketEvent) : void
      {
         var date:Date = null;
         var event:SocketEvent = param1;
         this.overData = event.data as FightOverInfo;
         this.isFightOver = true;
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_RESULT,this.overData));
         if(this.isEscape)
         {
            RemainHpManager.showChange();
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":this.overData}));
            MapManager.refMap(false);
            return;
         }
         if(this.overData.reason == 1)
         {
            this.isPlayerLost = true;
         }
         else if(this.overData.reason == 2)
         {
            this.isOvertime = true;
         }
         else if(this.overData.reason == 3)
         {
            this.isDraw = true;
         }
         else if(this.overData.reason == 4)
         {
            this.isSysError = true;
         }
         else if(this.overData.reason == 5)
         {
            this.isNpcEscape = true;
         }
         if(!this.isPlaySkillMovie && !this.isCatch && !this.isUsingItem)
         {
            RemainHpManager.showChange();
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":this.overData}));
         }
         date = new Date();
         setTimeout(function():void
         {
            MapManager.refMap(false);
         },1000);
      }
      
      private function execute(param1:Boolean = false) : void
      {
         var checkNPCChangedPet:uint = 0;
         checkNPCChangedPet = 0;
         var attackValue:AttackValue = null;
         var baseFighterMode:BaseFighterMode = null;
         if(!this.queue)
         {
            return;
         }
         if(this.queue.length > 0)
         {
            attackValue = this.queue.shift() as AttackValue;
            this.npcIsdied = attackValue.remainHP == 0 && attackValue.userID == 0;
            baseFighterMode = this.getFighterMode(attackValue.userID);
            baseFighterMode.useSkill(attackValue);
            if(attackValue.skillID != 0)
            {
               this.petContainer.addChild(baseFighterMode.petWin);
               TimerManager.clearTxt();
               this.isPlaySkillMovie = true;
            }
            else if(param1)
            {
               RemainHpManager.showChange();
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":this.overData}));
            }
            else
            {
               PetFightMsgManager.showText(attackValue);
               this.execute();
            }
         }
         else if(this.isReciveUseSkillCmd)
         {
            RemainHpManager.showChange();
            TimerManager.start();
            if(this.npcIsdied)
            {
               checkNPCChangedPet = uint(setInterval(function():void
               {
                  if(NpcChangePetData.npcPetChenged)
                  {
                     clearInterval(checkNPCChangedPet);
                     NpcChangePetData.npcPetChenged = false;
                     PlayerMode(FighterModeFactory.playerMode).nextRound();
                  }
               },100));
            }
            else
            {
               PlayerMode(FighterModeFactory.playerMode).nextRound();
            }
            this.isReciveUseSkillCmd = false;
         }
      }
      
      private function onAttackOver(param1:Event) : void
      {
         this.isPlaySkillMovie = false;
         var _loc2_:BaseFighterMode = param1.currentTarget as BaseFighterMode;
         if(this.isFightOver)
         {
            if(_loc2_.userID == this.overData.winnerID)
            {
               RemainHpManager.showChange();
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.FIGHT_CLOSE,{"data":this.overData}));
            }
            else
            {
               this.execute(true);
            }
         }
         else
         {
            this.execute();
         }
      }
      
      public function setup(param1:FightStartInfo) : void
      {
         var _loc2_:FightPetInfo = null;
         var _loc3_:BaseFighterMode = null;
         var _loc4_:Array = param1.infoArray;
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = FighterModeFactory.createMode(_loc2_,this.mainPanel);
            _loc3_.addEventListener(BaseFighterMode.ATTACK_OVER,this.onAttackOver);
            _loc3_.createView(this._mainPanel);
            this.hashMap.add(_loc3_.userID,_loc3_);
         }
         FighterModeFactory.playerMode.enemyMode = FighterModeFactory.enemyMode;
         FighterModeFactory.enemyMode.enemyMode = FighterModeFactory.playerMode;
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_NPC)
         {
            try
            {
               this.getFighterMode(0).propView.setHpTxtVisable(this.getFighterMode(MainManager.actorID).petID);
            }
            catch(error:Error)
            {
            }
         }
         PetFightMsgManager.showStartText();
         PlayerMode(FighterModeFactory.playerMode).checkIsCatch();
         this.addFightUI();
      }
      
      private function onUsePetItemOver(param1:PetFightEvent) : void
      {
         this.isUsingItem = false;
         this.execute();
      }
   }
}

