package com.robot.petFightModule.ui.controlPanel
{
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.pet.petWar.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.control.*;
   import com.robot.petFightModule.mode.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import gs.*;
   import gs.easing.*;
   import org.taomee.effect.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class SelectPetPanel extends BaseControlPanel implements IControlPanel, IAutoActionPanel
   {
      
      private var petIconArray:Array = [];
      
      private var replaceBtn:SimpleButton;
      
      private var index:uint = 0;
      
      private var blueGlowFilter:GlowFilter = new GlowFilter(438748,1,3,3,20);
      
      private var mode:BaseFighterMode;
      
      private var currentTime:uint;
      
      private var dropShadow:DropShadowFilter = new DropShadowFilter(3,45,0,0.6);
      
      private var yellowGlowFilter:GlowFilter = new GlowFilter(16776960,1,8,8,20);
      
      public function SelectPetPanel()
      {
         super();
         _panel = new ui_PetChangePanel();
         this.replaceBtn = panel["okBtn"];
         this.replaceBtn.addEventListener(MouseEvent.CLICK,this.clickHandler);
         this.mode = FighterModeFactory.playerMode;
         this.currentTime = this.mode.catchTime;
         this.initPanel();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.replaceBtn = null;
         this.petIconArray = [];
      }
      
      private function tweenPetIcon(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         for each(_loc2_ in this.petIconArray)
         {
            if(_loc2_ == param1)
            {
               TweenLite.to(_loc2_,0.3,{
                  "scaleX":1.5,
                  "scaleY":1.5,
                  "ease":Circ.easeOut
               });
               _loc2_.filters = [this.yellowGlowFilter,this.dropShadow];
            }
            else
            {
               TweenLite.to(_loc2_,0.3,{
                  "scaleX":0.8,
                  "scaleY":0.8,
                  "ease":Circ.easeOut
               });
               _loc2_.filters = [this.blueGlowFilter,this.dropShadow];
            }
         }
      }
      
      private function initPanel() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Array = null;
         var _loc3_:Number = 0;
         var _loc4_:MovieClip = null;
         this.index = 0;
         for each(_loc1_ in this.petIconArray)
         {
            DisplayUtil.removeAllChild(_loc1_);
            DisplayUtil.removeForParent(_loc1_);
         }
         this.petIconArray = [];
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc2_ = PetWarController.myCapA;
         }
         else
         {
            _loc2_ = PetManager.catchTimes;
         }
         var _loc5_:Number = 0;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = new PetIconMC();
            _loc4_.cacheAsBitmap = true;
            _loc4_.buttonMode = true;
            _loc4_.catchTime = _loc3_;
            _loc4_.x = 80 + 36 * _loc5_;
            _loc4_.y = 11;
            panel.addChild(_loc4_);
            this.petIconArray.push(_loc4_);
            if(_loc3_ == this.currentTime)
            {
               _loc4_.filters = [this.yellowGlowFilter,this.dropShadow];
               _loc4_.scaleX = _loc4_.scaleY = 1.2;
            }
            else
            {
               _loc4_.filters = [this.blueGlowFilter,this.dropShadow];
               _loc4_.scaleX = _loc4_.scaleY = 0.8;
            }
            _loc4_.addEventListener(MouseEvent.CLICK,this.showPet);
            _loc5_++;
         }
         this.loadPetIcon();
         this.showPet();
      }
      
      private function showPet(param1:MouseEvent = null) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Number = 0;
         var _loc4_:PetInfo = null;
         var _loc5_:PetSkillInfo = null;
         var _loc6_:MovieClip = null;
         var _loc7_:MovieClip = null;
         var _loc8_:String = null;
         this.clearSkillBtn();
         if(Boolean(param1))
         {
            _loc6_ = param1.currentTarget as MovieClip;
            _loc2_ = uint(_loc6_.catchTime);
            this.tweenPetIcon(_loc6_);
         }
         else
         {
            _loc2_ = uint(this.currentTime);
         }
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            _loc4_ = PetWarController.getPetInfo(_loc2_);
         }
         else
         {
            _loc4_ = PetManager.getPetInfo(_loc2_);
         }
         this.currentTime = _loc2_;
         panel["name_txt"].text = PetXMLInfo.getName(_loc4_.id);
         panel["level_txt"].text = "LV：" + _loc4_.level;
         panel["hp_txt"].text = _loc4_.hp + "/" + _loc4_.maxHp;
         panel["hpMC"].width = 110 * (_loc4_.hp / _loc4_.maxHp);
         var _loc9_:Number = 0;
         if(_loc4_.hp <= 0 || _loc2_ == this.mode.catchTime)
         {
            this.replaceBtn.mouseEnabled = false;
            this.replaceBtn.alpha = 0.5;
            this.replaceBtn.filters = [ColorFilter.setGrayscale()];
         }
         else
         {
            this.replaceBtn.mouseEnabled = true;
            this.replaceBtn.alpha = 1;
            this.replaceBtn.filters = [];
         }
         var _loc10_:Array = _loc4_.skillArray;
         var _loc11_:Number = 0;
         for each(_loc5_ in _loc10_)
         {
            if(_loc5_.id != 0)
            {
               _loc7_ = panel["skillMc_" + _loc11_];
               _loc7_["nameTxt"].text = _loc5_.name;
               _loc7_["migTxt"].text = "威力" + _loc5_.damage;
               _loc7_["ppTxt"].text = "PP" + _loc5_.pp + "/" + _loc5_.maxPP;
               _loc8_ = SkillXMLInfo.getTypeEN(_loc5_.id);
               _loc7_["iconMC"].gotoAndStop(_loc8_);
               _loc11_++;
            }
         }
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         SocketConnection.send(CommandID.CHANGE_PET,this.currentTime);
         (FighterModeFactory.playerMode as PlayerMode).subject.showFightPanel();
         FighterModeFactory.playerMode.catchTime = this.currentTime;
      }
      
      public function updateCurrent() : void
      {
         this.showPet();
      }
      
      private function loadPetIcon() : void
      {
         var url:String = null;
         var capT:uint = 0;
         var id:uint = 0;
         if(this.index == this.petIconArray.length)
         {
            return;
         }
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            capT = uint(PetWarController.myCapA[this.index]);
            id = uint(PetWarController.getPetInfo(capT).id);
         }
         else
         {
            capT = uint(PetManager.catchTimes[this.index]);
            id = uint(PetManager.getPetInfo(capT).id);
         }
         url = ClientConfig.getPetSwfPath(id);
         ResourceManager.getResource(url,function(param1:DisplayObject):void
         {
            var _showMc:MovieClip = null;
            _showMc = null;
            var sacle:Number = NaN;
            _showMc = null;
            var dis:DisplayObject = param1;
            _showMc = dis as MovieClip;
            if(Boolean(_showMc))
            {
               _showMc.gotoAndStop("rightdown");
               sacle = _showMc.height > 50 ? 0.5 : 1;
               _showMc.scaleX = _showMc.scaleY = sacle;
               _showMc.addEventListener(Event.ENTER_FRAME,function():void
               {
                  var _loc2_:MovieClip = _showMc.getChildAt(0) as MovieClip;
                  if(Boolean(_loc2_))
                  {
                     _loc2_.gotoAndStop(1);
                     _showMc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  }
               });
            }
            Sprite(petIconArray[index]["iconMC"]).addChild(_showMc);
            ++index;
            loadPetIcon();
         },"pet");
      }
      
      private function clearSkillBtn() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = 0;
         while(_loc2_ < 4)
         {
            _loc1_ = panel["skillMc_" + _loc2_];
            _loc1_["nameTxt"].text = "";
            _loc1_["migTxt"].text = "";
            _loc1_["ppTxt"].text = "";
            _loc1_["iconMC"].gotoAndStop(1);
            _loc2_++;
         }
      }
      
      public function auto() : void
      {
         var time:uint = 0;
         var count:uint = 0;
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            time = uint(PetWarController.getMyPet(count).catchTime);
         }
         else
         {
            time = uint(PetManager.catchTimes[count]);
         }
         try
         {
            if(PetFightModel.mode == PetFightModel.PET_MELEE)
            {
               while(PetWarController.getPetInfo(time).hp == 0)
               {
                  count++;
                  time = uint(PetWarController.getMyPet(count).catchTime);
               }
               this.currentTime = PetWarController.getPetInfo(time).catchTime;
            }
            else
            {
               while(PetManager.getPetInfo(time).hp == 0)
               {
                  count++;
                  time = uint(PetManager.catchTimes[count]);
               }
               this.currentTime = PetManager.getPetInfo(time).catchTime;
            }
            this.clickHandler(null);
         }
         catch(e:Error)
         {
            SocketConnection.send(CommandID.USE_SKILL,0);
            TimerManager.start();
         }
      }
   }
}

