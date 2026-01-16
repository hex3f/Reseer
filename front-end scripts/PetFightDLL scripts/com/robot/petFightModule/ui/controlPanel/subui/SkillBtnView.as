package com.robot.petFightModule.ui.controlPanel.subui
{
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.*;
   import com.robot.core.pet.petWar.*;
   import com.robot.core.ui.skillBtn.*;
   import com.robot.petFightModule.control.*;
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import org.taomee.effect.*;
   import org.taomee.utils.*;
   
   public class SkillBtnView extends EventDispatcher
   {
      
      private var outTF:TextFormat;
      
      private var overTF:TextFormat;
      
      private var isOpen:Boolean = true;
      
      private var mc:MovieClip;
      
      private var _pp:uint;
      
      private var maxPP:uint;
      
      private var _skillID:uint;
      
      public function SkillBtnView(param1:PetSkillInfo)
      {
         super();
         this.outTF = new TextFormat();
         this.outTF.color = 11138559;
         this.overTF = new TextFormat();
         this.overTF.color = 16763904;
         this.mc = new ui_skillMC();
         this._skillID = param1.id;
         this._pp = param1.pp;
         this.maxPP = param1.maxPP;
         this.mc["pp_txt"].text = this._pp + "/" + this.maxPP;
         this.mc["name_txt"].text = param1.name;
         var _loc2_:String = SkillXMLInfo.getTypeEN(this._skillID);
         this.mc["iconMC"].gotoAndStop(_loc2_);
         this.mc.addEventListener(MouseEvent.MOUSE_OVER,this.overHandler);
         this.mc.addEventListener(MouseEvent.MOUSE_OUT,this.outHandler);
         this.mc.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this.mc["pp_txt"].mouseEnabled = false;
         this.mc["name_txt"].mouseEnabled = false;
         this.mc.buttonMode = true;
         if(this._pp == 0)
         {
            this.mc.mouseChildren = false;
            this.mc.mouseEnabled = false;
            this.mc.enabled = false;
            this.mc.buttonMode = false;
            this.mc.filters = [ColorFilter.setGrayscale()];
         }
      }
      
      private function openBtns() : void
      {
         this.isOpen = true;
         if(this._pp > 0)
         {
            this.mc.mouseChildren = true;
            this.mc.mouseEnabled = true;
            this.mc.enabled = true;
            this.mc.buttonMode = true;
         }
      }
      
      public function get skillID() : uint
      {
         return this._skillID;
      }
      
      public function clear() : void
      {
         DisplayUtil.removeForParent(this.mc);
         this.mc = null;
      }
      
      public function get pp() : uint
      {
         return this._pp;
      }
      
      public function autoUse() : void
      {
         this.clickHandler(null);
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].alpha = 0;
         var _loc3_:TextField = _loc2_["name_txt"];
         _loc3_.setTextFormat(this.outTF);
         SkillInfoTip.hide();
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_["bgMC"].alpha = 0.5;
         var _loc3_:TextField = _loc2_["name_txt"];
         _loc3_.setTextFormat(this.overTF);
         SkillInfoTip.show(this._skillID);
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         var _loc2_:PetInfo = null;
         var _loc3_:PetSkillInfo = null;
         if(this._pp <= 0)
         {
            this._skillID = 0;
            dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL));
            return;
         }
         if(this._pp > 0)
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               _loc2_ = PetWarController.getPetInfo(FighterModeFactory.playerMode.catchTime);
            }
            else
            {
               _loc2_ = PetManager.getPetInfo(FighterModeFactory.playerMode.catchTime);
            }
            _loc3_ = _loc2_.getSkillInfo(this._skillID);
            if(Boolean(_loc3_))
            {
               --_loc3_.pp;
            }
            --this._pp;
            this.mc["pp_txt"].text = this._pp + "/" + this.maxPP;
            dispatchEvent(new PetFightEvent(PetFightEvent.USE_SKILL));
            if(this.pp == 0)
            {
               this.closeBtns();
            }
         }
      }
      
      private function closeBtns() : void
      {
         this.isOpen = false;
         this.mc.mouseChildren = false;
         this.mc.mouseEnabled = false;
         this.mc.enabled = false;
         this.mc.buttonMode = false;
      }
      
      public function changePP(param1:int) : void
      {
         this._pp += param1;
         if(this._pp > this.maxPP)
         {
            this._pp = this.maxPP;
         }
         else if(this._pp <= 0)
         {
            this._pp = 0;
         }
         this.mc["pp_txt"].text = this._pp + "/" + this.maxPP;
         if(this._pp > 0)
         {
            this.mc.mouseChildren = true;
            this.mc.mouseEnabled = true;
            this.mc.enabled = true;
            this.mc.buttonMode = true;
         }
         else if(this._pp == 0)
         {
            this.closeBtns();
         }
      }
      
      public function updatePP(param1:int) : void
      {
         this._pp = param1;
         if(this._pp > this.maxPP)
         {
            this._pp = this.maxPP;
         }
         else if(this._pp <= 0)
         {
            this._pp = 0;
         }
         this.mc["pp_txt"].text = this._pp + "/" + this.maxPP;
         if(this._pp > 0)
         {
            this.mc.mouseChildren = true;
            this.mc.mouseEnabled = true;
            this.mc.enabled = true;
            this.mc.buttonMode = true;
         }
         else if(this._pp == 0)
         {
            this.closeBtns();
         }
      }
      
      public function getMC() : MovieClip
      {
         return this.mc;
      }
   }
}

