package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.*;
   import com.robot.core.pet.petWar.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.subui.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.text.TextField;
   import org.taomee.effect.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PetSkillPanel extends BaseControlPanel implements IControlPanel, IAutoActionPanel
   {
      
      private var btnContainer:Sprite;
      
      private var petNameTxt:TextField;
      
      public var skillBtnArray:Array = [];
      
      private var petPrev:Sprite;
      
      private var _baseFighterMode:BaseFighterMode;
      
      protected var filte:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
      
      public function PetSkillPanel()
      {
         super();
         _panel = new ui_SkillPanel();
         this.petPrev = _panel["iconMC"];
         this.petNameTxt = _panel["nameTxt"];
         this.btnContainer = new Sprite();
         _panel.addChild(this.btnContainer);
         this.createSkillBtns();
      }
      
      public function openBtns() : void
      {
         this.btnContainer.mouseChildren = true;
         this.btnContainer.mouseEnabled = true;
         this.btnContainer.filters = [];
      }
      
      override public function get panel() : Sprite
      {
         return _panel;
      }
      
      public function closeBtns() : void
      {
         this.btnContainer.mouseChildren = false;
         this.btnContainer.mouseEnabled = false;
         this.btnContainer.filters = [ColorFilter.setGrayscale()];
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         var _showMc:MovieClip = null;
         _showMc = null;
         var o:DisplayObject = param1;
         _showMc = o as MovieClip;
         if(Boolean(_showMc))
         {
            _showMc.gotoAndStop("rightdown");
            _showMc.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            _showMc.scaleX = 1.5;
            _showMc.scaleY = 1.5;
            this.petPrev.addChild(_showMc);
         }
      }
      
      private function clearOldBtns() : void
      {
         var _loc1_:SkillBtnView = null;
         for each(_loc1_ in this.skillBtnArray)
         {
            _loc1_.removeEventListener(PetFightEvent.USE_SKILL,this.onSendSkill);
            _loc1_.clear();
         }
         this.skillBtnArray = [];
      }
      
      private function onSendSkill(param1:PetFightEvent) : void
      {
         var _loc2_:SkillBtnView = param1.currentTarget as SkillBtnView;
         dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL,_loc2_.skillID));
      }
      
      override public function destroy() : void
      {
         this.clearOldBtns();
         this.petPrev = null;
         this.petNameTxt = null;
         this.btnContainer = null;
         this.skillBtnArray = [];
      }
      
      public function createSkillBtns() : void
      {
         var _loc1_:Array = null;
         var _loc2_:PetSkillInfo = null;
         var _loc3_:SkillBtnView = null;
         var _loc4_:MovieClip = null;
         var _loc5_:BaseFighterMode = PetFightEntry.fighterCon.getFighterMode(MainManager.actorID);
         DisplayUtil.removeAllChild(this.petPrev);
         var _loc6_:uint = _loc5_.catchTime;
         this._baseFighterMode = _loc5_;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(_loc5_.skinId != 0 ? _loc5_.skinId : _loc5_.petID),this.onShowComplete,"pet");
         this.petNameTxt.text = _loc5_.petName;
         this.clearOldBtns();
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc1_ = PetWarController.getPetInfo(_loc5_.catchTime).skillArray;
         }
         else
         {
            _loc1_ = PetManager.getPetInfo(_loc6_).skillArray;
         }
         var _loc7_:Number = 0;
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_.id != 0)
            {
               _loc3_ = new SkillBtnView(_loc2_);
               _loc3_.addEventListener(PetFightEvent.USE_SKILL,this.onSendSkill);
               _loc4_ = _loc3_.getMC();
               _loc4_.x = 122 + (_loc4_.width + 5) * (_loc7_ % 2);
               _loc4_.y = 22 + (_loc4_.height + 7) * Math.floor(_loc7_ / 2);
               this.btnContainer.addChild(_loc4_);
               this.skillBtnArray.push(_loc3_);
               _loc7_++;
            }
         }
      }
      
      public function auto() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:SkillBtnView = this.skillBtnArray[0];
         while(_loc2_.pp == 0 && _loc1_ < this.skillBtnArray.length - 1)
         {
            _loc1_++;
            _loc2_ = this.skillBtnArray[_loc1_];
         }
         _loc2_.autoUse();
      }
   }
}

