package com.robot.petFightModule.ui
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.net.SocketConnection;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.ui.controlPanel.BaseControlPanel;
   import com.robot.petFightModule.ui.controlPanel.FightCatchItemPanel;
   import com.robot.petFightModule.ui.controlPanel.FightItemPanel;
   import com.robot.petFightModule.ui.controlPanel.IAutoActionPanel;
   import com.robot.petFightModule.ui.controlPanel.IControlPanel;
   import com.robot.petFightModule.ui.controlPanel.PetSkillPanel;
   import com.robot.petFightModule.ui.controlPanel.SelectPetPanel;
   import flash.events.Event;
   import gs.TweenLite;
   
   public class ControlPanelObserver extends BasePanelObserver implements IFightToolPanel
   {
      
      public static var autoAction:IAutoActionPanel;
      
      public static const ON_ADD_PANEL:String = "onAddPanel";
      
      public var skillPanel:PetSkillPanel;
      
      private var petPanel:SelectPetPanel;
      
      private var panels:Array = [];
      
      private var itemPanel:FightItemPanel;
      
      private var catchitemPanel:FightCatchItemPanel;
      
      public function ControlPanelObserver(param1:FightToolSubject)
      {
         super(param1);
      }
      
      private function hideAll() : void
      {
         var _loc1_:IControlPanel = null;
         for each(_loc1_ in this.panels)
         {
            TweenLite.to(_loc1_.panel,0.3,{"y":BaseControlPanel.PANEL_HEIGHT});
         }
      }
      
      private function onUseSkill(param1:PetFightEvent) : void
      {
         var _loc2_:uint = uint(param1.dataObj);
         SocketConnection.send(CommandID.USE_SKILL,_loc2_);
         subject.closePanel();
         TimerManager.wait();
      }
      
      public function changePet() : void
      {
         this.skillPanel.createSkillBtns();
      }
      
      public function init() : void
      {
         this.skillPanel = new PetSkillPanel();
         this.skillPanel.addEventListener(PetFightEvent.USE_SKILL,this.onUseSkill);
         this.itemPanel = new FightItemPanel();
         this.catchitemPanel = new FightCatchItemPanel();
         this.petPanel = new SelectPetPanel();
         this.addPanel(this.skillPanel,this.itemPanel,this.petPanel,this.catchitemPanel);
         TimerManager.autoAction = this.skillPanel;
      }
      
      public function open() : void
      {
         this.skillPanel.openBtns();
      }
      
      public function showFight() : void
      {
         TimerManager.autoAction = this.skillPanel;
         this.hideAll();
         TweenLite.to(this.skillPanel.panel,0.3,{"y":0});
      }
      
      private function addPanel(... rest) : void
      {
         var _loc2_:IControlPanel = null;
         for each(_loc2_ in rest)
         {
            if(this.panels.length > 0)
            {
               _loc2_.panel.y = BaseControlPanel.PANEL_HEIGHT;
            }
            this.panels.push(_loc2_);
            addChild(_loc2_.panel);
         }
         dispatchEvent(new Event(ON_ADD_PANEL));
      }
      
      public function showPet(param1:Boolean = false) : void
      {
         this.hideAll();
         TweenLite.to(this.petPanel.panel,0.3,{"y":0});
         if(param1)
         {
            TimerManager.autoAction = this.petPanel;
         }
         PetFightEntry.isAutoSelectPet = param1;
         this.petPanel.updateCurrent();
      }
      
      public function showItem() : void
      {
         this.hideAll();
         TweenLite.to(this.itemPanel.panel,0.3,{"y":0});
      }
      
      public function showCatchItem() : void
      {
         this.hideAll();
         TweenLite.to(this.catchitemPanel.panel,0.3,{"y":0});
      }
      
      public function close() : void
      {
         this.showFight();
         this.skillPanel.closeBtns();
      }
      
      override public function destroy() : void
      {
         var _loc1_:IControlPanel = null;
         super.destroy();
         for each(_loc1_ in this.panels)
         {
            _loc1_.destroy();
         }
         this.panels = [];
         this.skillPanel = null;
         this.itemPanel = null;
         this.petPanel = null;
      }
   }
}

