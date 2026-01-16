package com.robot.petFightModule.mode
{
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.info.fightInfo.FightPetInfo;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.data.*;
   import com.robot.petFightModule.ui.*;
   import com.robot.petFightModule.view.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PlayerMode extends BaseFighterMode
   {
      
      private var isPetNoBlood:Boolean = false;
      
      private var conPanelObserver:ControlPanelObserver;
      
      private var controlContainer:Sprite;
      
      public var subject:FightToolSubject;
      
      private var toolBtnObserver:ToolBtnPanelObserver;
      
      public function PlayerMode(param1:FightPetInfo, param2:Sprite)
      {
         super(param1,param2);
         this.controlContainer = param2["controlMC"];
         this.subject = new FightToolSubject();
         this.toolBtnObserver = new ToolBtnPanelObserver(this.subject,this.controlContainer);
         EventManager.addEventListener(PetFightEvent.USE_PET_ITEM,this.usePetItemHandler);
         this.subject.closePanel();
      }
      
      public function checkIsCatch() : void
      {
         this.toolBtnObserver.isCanCatch();
      }
      
      override public function createView(param1:Sprite) : void
      {
         var _loc2_:Sprite = null;
         initSkillCon();
         _loc2_ = param1["MyInfoPanel"];
         _propView = new PlayerPropView(_loc2_);
         _propView.update(this);
         _petWin = new PlayerPetWin();
         _petWin.addEventListener(PetFightEvent.ON_OPENNING,this.onOpenning);
         _petWin.update(petID,skinId);
      }
      
      public function get skillBtnViews() : Array
      {
         return this.conPanelObserver.skillPanel.skillBtnArray;
      }
      
      private function removePanelBG(param1:Event) : void
      {
         var _loc2_:MovieClip = this.controlContainer["panelBgMC"];
         DisplayUtil.removeForParent(_loc2_);
         this.subject.openPanel();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.controlContainer = null;
         this.conPanelObserver = null;
         this.toolBtnObserver = null;
         this.subject.destroy();
         this.subject = null;
         EventManager.removeEventListener(PetFightEvent.USE_PET_ITEM,this.usePetItemHandler);
      }
      
      override public function changePet(param1:ChangePetInfo) : void
      {
         super.changePet(param1);
         this.conPanelObserver.changePet();
         this.subject.showFightPanel();
         if(PetFightEntry.isAutoSelectPet)
         {
            this.subject.openPanel();
         }
         else
         {
            this.subject.closePanel();
         }
      }
      
      override protected function onNoBloodHandler(param1:PetFightEvent) : void
      {
         this.subject.closePanel();
         this.subject.showPetPanel(true);
      }
      
      public function nextRound() : void
      {
         var _loc1_:BaseFighterMode = null;
         var _loc2_:ChangePetInfo = NpcChangePetData.first();
         if(Boolean(_loc2_))
         {
            _loc1_ = PetFightEntry.fighterCon.getFighterMode(_loc2_.userID);
            NpcChangePetData.npcPetChenged = false;
            _loc1_.changePet(_loc2_);
         }
         this.subject.openPanel();
         if(this.hp == 0)
         {
            this.dispatchEvent(new PetFightEvent(PetFightEvent.NO_BLOOD));
         }
      }
      
      override protected function onOpenning(param1:PetFightEvent) : void
      {
         super.onOpenning(param1);
         this.conPanelObserver = new ControlPanelObserver(this.subject);
         this.conPanelObserver.addEventListener(ControlPanelObserver.ON_ADD_PANEL,this.removePanelBG);
         this.conPanelObserver.init();
         this.controlContainer.addChild(this.conPanelObserver);
         TimerManager.start();
      }
      
      private function usePetItemHandler(param1:PetFightEvent) : void
      {
         TimerManager.wait();
         this.subject.showFightPanel();
         this.subject.closePanel();
      }
   }
}

