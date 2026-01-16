package com.robot.petFightModule.mode
{
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.*;
   import com.robot.core.pet.petWar.*;
   import com.robot.core.ui.alert.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.control.*;
   import com.robot.petFightModule.ui.controlPanel.subui.SkillBtnView;
   import com.robot.petFightModule.view.*;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.filters.*;
   
   public class BaseFighterMode extends EventDispatcher
   {
      
      public static const ATTACK_OVER:String = "attackOver";
      
      public static const StartNextRound:String = "start_next_round";
      
      public var level:uint;
      
      private var _userID:uint;
      
      protected var _propView:BaseFighterPropView;
      
      public var hp:int;
      
      protected var enemy:BaseFighterMode;
      
      public var petName:String;
      
      public var catchable:Boolean;
      
      protected var _petWin:BaseFighterPetWin;
      
      public var changeHp:Number;
      
      public var catchTime:uint;
      
      public var maxHP:uint;
      
      public var skillCon:UseSkillController;
      
      public var petID:uint;
      
      public var skinId:uint;
      
      public var petType:uint;
      
      public function BaseFighterMode(param1:FightPetInfo, param2:Sprite)
      {
         super();
         this._userID = param1.userID;
         this.petID = param1.petID;
         var _loc3_:PetInfo = PetFightEntry._petInfoMap.getValue(param1.catchTime);
         this.skinId = _loc3_.skinID;
         this.petName = PetXMLInfo.getName(this.petID);
         this.catchTime = param1.catchTime;
         this.hp = param1.hp;
         this.maxHP = param1.maxHP;
         this.level = param1.level;
         this.catchable = param1.catchable;
         addEventListener(PetFightEvent.NO_BLOOD,this.onNoBloodHandler);
         addEventListener(PetFightEvent.REMAIN_HP,this.onItemRemainHp);
      }
      
      public function createView(param1:Sprite) : void
      {
         var _loc2_:Sprite = null;
         this.initSkillCon();
         _loc2_ = param1["OtherInfoPanel"];
         this._propView = new BaseFighterPropView(_loc2_);
         this._propView.update(this);
         this._petWin = new BaseFighterPetWin();
         this._petWin.addEventListener(PetFightEvent.ON_OPENNING,this.onOpenning);
         this._petWin.update(this.petID,this.skinId);
         if(MainManager.actorInfo.maxPuniLv == 2)
         {
            if(this.petID == 300 && this._userID == 0)
            {
               this._petWin.petMC.filters = null;
               this._petWin.petMC.filters = [new GlowFilter(16724736,1,20,20,1.6)];
            }
         }
      }
      
      private function onItemRemainHp(param1:PetFightEvent) : void
      {
         var _loc2_:uint = uint(param1.dataObj);
         this.hp = _loc2_;
         this.propView.resetBar(this);
      }
      
      public function destroy() : void
      {
         removeEventListener(PetFightEvent.NO_BLOOD,this.onNoBloodHandler);
         removeEventListener(PetFightEvent.REMAIN_HP,this.onItemRemainHp);
         this.skillCon.removeEventListener(PetFightEvent.LOST_HP,this.lostHpHandler);
         this.skillCon.removeEventListener(PetFightEvent.GAIN_HP,this.gainHpHandler);
         this.skillCon.removeEventListener(PetFightEvent.REMAIN_HP,this.remainHpHandler);
         this.skillCon.removeEventListener(UseSkillController.MOVIE_OVER,this.onMovieOver);
         this.skillCon.destroy();
         this.skillCon = null;
         this._propView.destroy();
         this._propView = null;
         this._petWin.removeEventListener(PetFightEvent.ON_OPENNING,this.onOpenning);
         this._petWin.destroy();
         this._petWin = null;
      }
      
      public function get enemyMode() : BaseFighterMode
      {
         return this.enemy;
      }
      
      protected function onOpenning(param1:PetFightEvent) : void
      {
      }
      
      public function changePet(param1:ChangePetInfo) : void
      {
         this.petID = param1.petID;
         var _loc2_:PetInfo = PetFightEntry._petInfoMap.getValue(param1.catchTime);
         this.skinId = _loc2_.skinID;
         this.petName = PetXMLInfo.getName(this.petID);
         this.level = param1.level;
         this.hp = param1.hp;
         this.maxHP = param1.maxHp;
         this._propView.update(this,true);
         this._petWin.update(this.petID,this.skinId);
         if(this == FighterModeFactory.playerMode)
         {
            TimerManager.start();
         }
      }
      
      public function useSkill(param1:AttackValue) : void
      {
         var _loc7_:int = 0;
         var _loc8_:SkillBtnView = null;
         var _loc9_:int = 0;
         var _loc10_:PetSkillInfo = null;
         var _loc2_:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
         var _loc3_:ColorMatrixFilter = null;
         var _loc4_:GlowFilter = null;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         this.skillCon.action(param1);
         TimerManager.clearTxt();
         if(param1.skillID != 0)
         {
            PetFightMsgManager.showText(param1);
         }
         if(param1.userID == MainManager.actorInfo.userID)
         {
            _loc7_ = 0;
            while(_loc7_ < PlayerMode(this).skillBtnViews.length)
            {
               _loc8_ = PlayerMode(this).skillBtnViews[_loc7_];
               _loc9_ = 0;
               while(_loc9_ < param1.skillInfoArray.length)
               {
                  _loc10_ = param1.skillInfoArray[_loc9_];
                  if(_loc8_.skillID == _loc10_.id)
                  {
                     _loc8_.updatePP(_loc10_.pp);
                  }
                  _loc9_++;
               }
               _loc7_++;
            }
         }
         if(param1.state == 1)
         {
            _loc5_ = [0.25,3.3,-2.6,-0.1,0,0.4,0.4,0.5,-0.22,0,0.4,0.3,0.4,-0.26,0,0,0,0,1,0];
            _loc6_ = [0,0,0,0,0];
            _loc3_ = new ColorMatrixFilter(_loc5_);
            _loc4_ = new GlowFilter(uint(_loc6_[0]),int(_loc6_[1]),int(_loc6_[2]),int(_loc6_[3]),int(_loc6_[4]));
            this._petWin.petMC.filters = null;
            this._petWin.petMC.filters = [_loc2_,_loc4_,_loc3_];
         }
         if(param1.state == 2)
         {
            _loc5_ = [0.9,0,0.8,0,0,1,0,0.2,0,0,1,0,0.2,0,0,0,0,0,1,0];
            _loc6_ = [0,0,0,0,0];
            _loc3_ = new ColorMatrixFilter(_loc5_);
            _loc4_ = new GlowFilter(uint(_loc6_[0]),int(_loc6_[1]),int(_loc6_[2]),int(_loc6_[3]),int(_loc6_[4]));
            this._petWin.petMC.filters = null;
            this._petWin.petMC.filters = [_loc2_,_loc4_,_loc3_];
         }
         if(param1.state == 12)
         {
            this._petWin.petMC.filters = null;
            this._petWin.petMC.filters = [new GlowFilter(4456539,1,20,20,1.6)];
         }
         else if(param1.state == 13)
         {
            this._petWin.petMC.filters = null;
            this._petWin.petMC.filters = [new GlowFilter(16776960,1,20,20,1.2)];
         }
         if(param1.state == 0)
         {
            this._petWin.petMC.filters = null;
         }
      }
      
      public function remainHp(param1:uint) : void
      {
         var _loc2_:PetInfo = null;
         var _loc3_:Number = param1 - this.hp;
         this.hp = param1;
         this.propView.resetBar(this,true);
         this.skillCon.showChangeTxt(_loc3_);
         if(this.userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc2_ = PetWarController.getPetInfo(this.catchTime);
            }
            else
            {
               _loc2_ = PetManager.getPetInfo(this.catchTime);
            }
            _loc2_.hp = this.hp;
         }
      }
      
      private function onMovieOver(param1:Event) : void
      {
         dispatchEvent(new Event(ATTACK_OVER));
      }
      
      private function lostHpHandler(param1:PetFightEvent) : void
      {
         var _loc2_:PetInfo = null;
         var _loc3_:Number = Number(param1.dataObj);
         this.enemy.hp -= _loc3_;
         if(this.enemy.hp < 0)
         {
            this.enemy.hp = 0;
         }
         this.enemy.propView.resetBar(this.enemy);
         if(this.enemy.userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc2_ = PetWarController.getPetInfo(this.catchTime);
            }
            else
            {
               _loc2_ = PetManager.getPetInfo(this.catchTime);
            }
            if(Boolean(_loc2_))
            {
               _loc2_.hp = this.enemy.hp;
            }
         }
      }
      
      protected function initSkillCon() : void
      {
         this.skillCon = new UseSkillController(this);
         this.skillCon.addEventListener(PetFightEvent.LOST_HP,this.lostHpHandler);
         this.skillCon.addEventListener(PetFightEvent.GAIN_HP,this.gainHpHandler);
         this.skillCon.addEventListener(PetFightEvent.REMAIN_HP,this.remainHpHandler);
         this.skillCon.addEventListener(UseSkillController.MOVIE_OVER,this.onMovieOver);
      }
      
      private function gainHpHandler(param1:PetFightEvent) : void
      {
         var _loc2_:PetInfo = null;
         var _loc3_:Number = Number(param1.dataObj);
         this.hp += _loc3_;
         if(this.hp < 0)
         {
            this.hp = 0;
         }
         if(this.hp > this.maxHP)
         {
            this.hp = this.maxHP;
         }
         this.propView.resetBar(this);
         if(this.userID == MainManager.actorID)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc2_ = PetWarController.getPetInfo(this.catchTime);
            }
            else
            {
               _loc2_ = PetManager.getPetInfo(this.catchTime);
            }
            _loc2_.hp = this.hp;
         }
         param1.fun();
      }
      
      public function catchPet(param1:CatchPetInfo = null) : void
      {
         if(!param1)
         {
            this.petWin.catchFail();
         }
         else if(param1.catchTime == 0)
         {
            this.petWin.catchFail();
         }
         else
         {
            this.petWin.catchSuccess(param1);
         }
      }
      
      private function remainHpHandler(param1:PetFightEvent) : void
      {
         var _loc2_:Number = Number(param1.dataObj);
         RemainHpManager.add(this,_loc2_);
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
      
      public function set enemyMode(param1:BaseFighterMode) : void
      {
         this.enemy = param1;
      }
      
      public function get propView() : BaseFighterPropView
      {
         return this._propView;
      }
      
      public function get petWin() : BaseFighterPetWin
      {
         return this._petWin;
      }
      
      protected function onNoBloodHandler(param1:PetFightEvent) : void
      {
      }
   }
}

