package com.robot.petFightModule.view
{
   import com.robot.core.config.*;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.manager.UIManager;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.text.TextField;
   import flash.utils.*;
   import gs.TweenLite;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class BaseFighterPropView
   {
      
      protected var effectIconClsNames:Array = [];
      
      protected var iconMC:MovieClip;
      
      protected var effectIcons:Array = [];
      
      protected var effectTraitIcons:Array = [];
      
      protected var _propWin:Sprite;
      
      protected var barMC:MovieClip;
      
      protected var hp_txt:TextField;
      
      protected var typeIcon:MovieClip;
      
      protected var lv_txt:TextField;
      
      protected var name_txt:TextField;
      
      private var _baseFighterMode:BaseFighterMode;
      
      protected var filte:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
      
      protected var shieldIconView:ShieldIconView;
      
      private var skillIconLoadPanel:MLoadPane;
      
      private var petType:Number;
      
      private var value:AttackValue;
      
      public function BaseFighterPropView(param1:Sprite)
      {
         super();
         this._propWin = param1;
         this.typeIcon = param1["typeIcon"];
         this.barMC = param1["hpBar"]["barMC"];
         this.iconMC = param1["iconMC"];
         this.lv_txt = param1["level_txt"];
         this.hp_txt = param1["hp_txt"];
         this.name_txt = param1["name_txt"];
         if(this._propWin.name == "OtherInfoPanel")
         {
            this.hp_txt.visible = false;
         }
      }
      
      public function destroy() : void
      {
         this._propWin = null;
         this.barMC = null;
         this.iconMC = null;
         this.lv_txt = null;
         this.hp_txt = null;
         this.name_txt = null;
         if(this.shieldIconView != null)
         {
            this.shieldIconView.destory();
            this.shieldIconView = null;
         }
         this.skillIconLoadPanel.destroy();
         this.skillIconLoadPanel = null;
      }
      
      public function resetBar(param1:BaseFighterMode, param2:Boolean = false) : void
      {
         var bmp:Bitmap = null;
         var p:Number = NaN;
         bmp = null;
         var mode:BaseFighterMode = param1;
         var isDispatch:Boolean = param2;
         if(mode.hp <= 0)
         {
            p = 0;
         }
         else if(mode.maxHP == 0)
         {
            p = 1;
         }
         else
         {
            p = mode.hp / mode.maxHP;
         }
         try
         {
            bmp = DisplayUtil.copyDisplayAsBmp(this.barMC);
            DisplayUtil.FillColor(bmp,16711680);
            bmp.alpha = 0.4;
            bmp.x = this.barMC.x;
            bmp.y = this.barMC.y;
            this.barMC.parent.addChild(bmp);
            this.barMC.parent.swapChildren(bmp,this.barMC);
            TweenLite.to(bmp,1.2,{
               "scaleX":p,
               "onComplete":function():void
               {
                  DisplayUtil.removeForParent(bmp);
                  bmp.bitmapData.dispose();
                  bmp = null;
               }
            });
         }
         catch(e:Error)
         {
         }
         this.barMC.scaleX = p;
         if(Boolean(this.hp_txt))
         {
            this.hp_txt.text = mode.hp.toString() + "/" + mode.maxHP.toString();
         }
      }
      
      public function update(param1:BaseFighterMode, param2:Boolean = false) : void
      {
         if(param2)
         {
            this.removeAllEffect();
         }
         DisplayUtil.removeAllChild(this.iconMC);
         if(Boolean(this.skillIconLoadPanel))
         {
            this.skillIconLoadPanel.unload();
            this.skillIconLoadPanel.destroy();
            this.skillIconLoadPanel = null;
         }
         if(param1.level <= 100)
         {
            this.lv_txt.text = param1.level.toString();
         }
         else
         {
            this.lv_txt.text = "??";
         }
         this.showName(param1);
         this.resetBar(param1);
         this.addPetPropIcon(param1);
         this._baseFighterMode = param1;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1.petID),this.onShowComplete,"pet");
         if(this.shieldIconView == null)
         {
            this.shieldIconView = new ShieldIconView(this._propWin["shield"],param1.userID);
         }
      }
      
      private function addPetPropIcon(param1:BaseFighterMode) : void
      {
         var _loc2_:Bitmap = null;
         this.skillIconLoadPanel = new MLoadPane(null,MLoadPane.FIT_ALL,MLoadPane.MIDDLE,MLoadPane.MIDDLE);
         this.skillIconLoadPanel.setSizeWH(18,18);
         this.skillIconLoadPanel.x = this.typeIcon.x + 3;
         this.skillIconLoadPanel.y = this.typeIcon.y + 3;
         var _loc3_:String = PetXMLInfo.getType(param1.petID);
         var _loc4_:SimpleButton = UIManager.getButton("Icon_PetType_" + _loc3_);
         if(Boolean(_loc4_))
         {
            _loc2_ = DisplayUtil.copyDisplayAsBmp(_loc4_);
            _loc2_.x = 0;
            _loc2_.y = 0;
            this.skillIconLoadPanel.setIcon(_loc2_);
            this._propWin.addChild(this.skillIconLoadPanel);
         }
      }
      
      public function upPetPropIcon(param1:AttackValue) : void
      {
         var _loc2_:Bitmap = null;
         var _loc3_:uint = 0;
         var _loc4_:SimpleButton = null;
         if(Boolean(this.skillIconLoadPanel))
         {
            this.skillIconLoadPanel.unload();
            this.skillIconLoadPanel.destroy();
            this.skillIconLoadPanel = null;
            _loc2_ = null;
            this.skillIconLoadPanel = new MLoadPane(null,MLoadPane.FIT_ALL,MLoadPane.MIDDLE,MLoadPane.MIDDLE);
            this.skillIconLoadPanel.setSizeWH(18,18);
            this.skillIconLoadPanel.x = this.typeIcon.x + 3;
            this.skillIconLoadPanel.y = this.typeIcon.y + 3;
            _loc3_ = uint(param1.getPetType);
            _loc4_ = UIManager.getButton("Icon_PetType_" + _loc3_);
            if(Boolean(_loc4_))
            {
               _loc2_ = DisplayUtil.copyDisplayAsBmp(_loc4_);
               _loc2_.x = 0;
               _loc2_.y = 0;
               this.skillIconLoadPanel.setIcon(_loc2_);
               this._propWin.addChild(this.skillIconLoadPanel);
            }
         }
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         var _showMc:MovieClip = null;
         _showMc = null;
         var sacle:Number = NaN;
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
            sacle = _showMc.width > 30 ? 1 : 1.5;
            _showMc.scaleX = sacle;
            _showMc.scaleY = sacle;
            DisplayUtil.stopAllMovieClip(_showMc);
            this.iconMC.addChild(_showMc);
         }
      }
      
      public function addEffect(param1:Class, param2:uint, param3:uint) : void
      {
         var _loc4_:MovieClip = new param1() as MovieClip;
         var _loc5_:String = getQualifiedClassName(_loc4_);
         if(this.effectIconClsNames.indexOf(_loc5_) == -1)
         {
            if(param2 == 11)
            {
               _loc4_.gotoAndStop(param3);
            }
            this.addIcon(_loc4_);
            this.effectIconClsNames.push(_loc5_);
            this.effectIcons.push(_loc4_);
            _loc4_.buttonMode = true;
            ToolTipManager.add(_loc4_,PetFightMsgManager.STATUS_ARRAY[param2] + ":" + param3.toString() + "回合");
         }
      }
      
      public function addEffectTrait(param1:Class, param2:uint, param3:int) : void
      {
         var _loc4_:MovieClip = new param1() as MovieClip;
         _loc4_.gotoAndStop(param2 + 1);
         _loc4_.scaleX = _loc4_.scaleY = 0.9;
         var _loc5_:String = getQualifiedClassName(_loc4_) + param2;
         if(this.effectIconClsNames.indexOf(_loc5_) == -1)
         {
            this.addTraitIcon(_loc4_);
            this.effectIconClsNames.push(_loc5_);
            this.effectTraitIcons.push(_loc4_);
            _loc4_.buttonMode = true;
            ToolTipManager.add(_loc4_,PetFightMsgManager.TRAIT_STATUS_ARRAY[param2] + ":" + param3.toString() + "级");
         }
      }
      
      protected function showName(param1:BaseFighterMode) : void
      {
         if(param1.userID == 0)
         {
            this.name_txt.htmlText = "<font color=\'#ffff00\'>" + param1.petName + "</font>";
         }
         else if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
         {
            this.name_txt.htmlText = PetFightModel.enemyName;
         }
         else if(PetFightModel.status == PetFightModel.FIGHT_WITH_NPC)
         {
            this.name_txt.htmlText = "<font color=\'#ffff00\'>野生精灵</font>";
         }
         else if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS)
         {
            this.name_txt.htmlText = "<font color=\'#ffff00\'>" + PetFightModel.enemyName + "</font>";
         }
      }
      
      protected function initExp(param1:BaseFighterMode) : void
      {
      }
      
      public function removeAllEffect() : void
      {
         var _loc1_:MovieClip = null;
         this.effectIconClsNames = [];
         for each(_loc1_ in this.effectIcons)
         {
            ToolTipManager.remove(_loc1_);
            DisplayUtil.removeForParent(_loc1_);
         }
         for each(_loc1_ in this.effectTraitIcons)
         {
            ToolTipManager.remove(_loc1_);
            DisplayUtil.removeForParent(_loc1_);
         }
         this.effectIcons = [];
         this.effectTraitIcons = [];
      }
      
      protected function addIcon(param1:MovieClip) : void
      {
         var _loc2_:Number = 100 - (param1.width + 4) * this.effectIcons.length;
         var _loc3_:Number = 32;
         var _loc4_:Point = this._propWin.parent.globalToLocal(this._propWin.localToGlobal(new Point(_loc2_,_loc3_)));
         param1.x = _loc4_.x;
         param1.y = _loc4_.y;
         this._propWin.parent.addChild(param1);
      }
      
      protected function addTraitIcon(param1:MovieClip) : void
      {
         var _loc2_:Number = this._propWin.name == "OtherInfoPanel" ? 318 - (param1.width * 0.9 + 4) * this.effectTraitIcons.length : -12 + (param1.width * 0.9 + 4) * this.effectTraitIcons.length;
         var _loc3_:Number = this._propWin.name == "OtherInfoPanel" ? 65 : 65;
         var _loc4_:Point = this._propWin.parent.globalToLocal(this._propWin.localToGlobal(new Point(_loc2_,_loc3_)));
         param1.x = _loc4_.x;
         param1.y = _loc4_.y;
         this._propWin.parent.addChild(param1);
      }
      
      public function setHpTxtVisable(param1:int) : void
      {
         this.hp_txt.visible = [10,11,12,164,165,166].indexOf(param1) > -1;
      }
   }
}

