package com.robot.petFightModule.view
{
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.*;
   import com.robot.core.manager.*;
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.control.UseSkillController;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.*;
   import flash.text.TextField;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class ShieldIconView
   {
      
      private var _icon:MovieClip;
      
      private var _uid:int;
      
      private var _shieldNum:int;
      
      private var _attData:AttackValue;
      
      private var _fighterModel:BaseFighterMode;
      
      private var _otherFighterModel:BaseFighterMode;
      
      private var _playerModel:BaseFighterMode;
      
      private var _otherFighterUseSkillCon:UseSkillController;
      
      public function ShieldIconView(param1:MovieClip, param2:int)
      {
         super();
         ToolTipManager.add(param1,"精灵护盾");
         this._icon = param1;
         this._icon.visible = false;
         this._uid = param2;
         this.delataNumTxt.visible = false;
         this._icon.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._icon["numTxt"].text = "0";
      }
      
      private function onEnterFrame(param1:*) : void
      {
         if(FighterModeFactory.enemyMode != null && FighterModeFactory.playerMode != null)
         {
            this.addEvent();
            this._icon.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function addEvent() : void
      {
         EventManager.addEventListener(PetFightEvent.USE_SKILL_SUC_ATTACK,this.onUseSkillAtck);
         this._fighterModel = BaseFighterMode(PetFightEntry.fighterCon.getFighterMode(this._uid));
         this._otherFighterModel = this._uid == MainManager.actorID ? FighterModeFactory.enemyMode : FighterModeFactory.playerMode;
         this._otherFighterUseSkillCon = this._otherFighterModel.skillCon;
         this._otherFighterUseSkillCon.addEventListener(UseSkillController.MOVIE_OVER,this.onBeAttacked);
      }
      
      private function onUseSkillAtck(param1:PetFightEvent) : void
      {
         var _loc2_:UseSkillInfo = param1.dataObj as UseSkillInfo;
         if(_loc2_.firstAttackInfo.userID == this._uid)
         {
            this._attData = _loc2_.firstAttackInfo;
         }
         else
         {
            this._attData = _loc2_.secondAttackInfo;
         }
         this.onRoundStart();
      }
      
      public function onRoundStart(param1:* = null) : void
      {
         if(this._attData == null)
         {
            this._icon.visible = false;
            return;
         }
         if(this._shieldNum == 0)
         {
            this._icon.visible = false;
         }
         if(this._attData.maxShield > 0)
         {
            this._icon.visible = true;
         }
         else
         {
            this._icon.visible = false;
         }
         this._shieldNum = this._attData.maxShield;
         this._icon["numTxt"].text = this._attData.maxShield;
      }
      
      public function onAttackOver(param1:* = null) : void
      {
         if(this._attData == null)
         {
            return;
         }
         this.shieldNum = this._attData.curShield;
      }
      
      private function onBeAttacked(param1:* = null) : void
      {
         if(this._attData == null)
         {
            return;
         }
         if(this.isSelf)
         {
         }
         this.shieldNum = this._attData.curShield;
      }
      
      private function onRoundOver(param1:* = null) : void
      {
         var tKey:int = 0;
         var e:* = param1;
         if(this._attData == null)
         {
            return;
         }
         tKey = int(setTimeout(function():void
         {
            if(_attData != null)
            {
               shieldNum = _attData.curShield;
            }
         },300));
      }
      
      public function set shieldNum(param1:int) : void
      {
         if(this._icon == null)
         {
            return;
         }
         var _loc2_:int = param1 - this._shieldNum;
         this.playDeltaNum(_loc2_);
         this._shieldNum = param1;
         this._icon["numTxt"].text = param1;
      }
      
      public function playDeltaNum(param1:int) : void
      {
         var deltaNum:int = param1;
         if(deltaNum == 0)
         {
            return;
         }
         this.delataNumTxt.text = deltaNum + "";
         if(deltaNum > 0)
         {
            this.delataNumTxt.text = "+ " + deltaNum;
         }
         this.delataNumTxt.y = 29.5;
         this.delataNumTxt.alpha = 1;
         this.delataNumTxt.visible = true;
         TweenLite.killTweensOf(this.delataNumTxt);
         if(this.delataNumTxt == null)
         {
            return;
         }
         TweenLite.to(this.delataNumTxt,1.5,{
            "y":-10,
            "onComplete":function():void
            {
               if(_icon == null)
               {
                  return;
               }
               delataNumTxt.visible = false;
            }
         });
      }
      
      public function get delataNumTxt() : TextField
      {
         return this._icon["deltaNumTxt"];
      }
      
      public function destory() : void
      {
         ToolTipManager.remove(this._icon);
         this._otherFighterUseSkillCon.removeEventListener(UseSkillController.MOVIE_OVER,this.onBeAttacked);
         this._fighterModel = null;
         this._playerModel = null;
         this._otherFighterModel = null;
         this._otherFighterUseSkillCon = null;
         EventManager.removeEventListener(PetFightEvent.USE_SKILL_SUC_ATTACK,this.onUseSkillAtck);
         this._icon = null;
      }
      
      private function get isSelf() : Boolean
      {
         return this._uid == MainManager.actorID;
      }
      
      private function get logPrefix() : String
      {
         return this.isSelf ? "left" : "right";
      }
   }
}

