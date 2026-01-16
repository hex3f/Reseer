package com.robot.petFightModule.control
{
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.manager.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.animatorCon.*;
   import com.robot.petFightModule.assetManager.*;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.view.BaseFighterPropView;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.text.*;
   import flash.utils.*;
   import gs.*;
   import org.taomee.utils.*;
   
   public class UseSkillController extends EventDispatcher
   {
      
      public static const MOVIE_START:String = "movieStart";
      
      public static const MOVIE_OVER:String = "movieOver";
      
      private static const DECORATOR_PATH:String = "com.robot.petFight.animatorCon.decorator.AnimatorDecorator_";
      
      private var tf2:TextFormat;
      
      private var tf3:TextFormat;
      
      private var hpTxt:TextField;
      
      private var gainHpTxt:TextField;
      
      private var lostHp:Number;
      
      private var remainHp:Number;
      
      private var LABEL_ARRAY:Array = ["","attack","sa","","cp"];
      
      private var subMC:MovieClip;
      
      private var attackMC:MovieClip;
      
      public var isDispatchByChangeTxt:Boolean;
      
      private var defenceMC:MovieClip;
      
      private var gainHp:Number;
      
      private var playerMode:BaseFighterMode;
      
      private var useSkillID:int;
      
      private var animator:AbstractAnimatorCon;
      
      private var value:AttackValue;
      
      private var tf:TextFormat;
      
      private var changeHpTxt:TextField;
      
      private var timer:Timer = null;
      
      private var attackValue:AttackValue;
      
      private var hpMc:MovieClip;
      
      private var playLabel:String;
      
      public function UseSkillController(param1:BaseFighterMode)
      {
         super();
         this.playerMode = param1;
         this.tf = new TextFormat();
         this.tf.font = "Arial";
         this.tf.color = 10027008;
         this.tf.size = 45;
         this.tf.bold = true;
         this.tf.align = TextFormatAlign.CENTER;
         this.tf2 = new TextFormat();
         this.tf2.font = "Arial";
         this.tf2.color = 52224;
         this.tf2.size = 45;
         this.tf2.bold = true;
         this.tf2.align = TextFormatAlign.CENTER;
         this.tf3 = new TextFormat();
         this.tf3.font = "Arial";
         this.tf3.color = 16724735;
         this.tf3.size = 45;
         this.tf3.bold = true;
         this.tf3.align = TextFormatAlign.CENTER;
         this.hpTxt = new TextField();
         this.hpTxt.autoSize = TextFieldAutoSize.CENTER;
         this.hpTxt.filters = [new GlowFilter(16776960,1,6,6,5)];
         this.hpTxt.width = 150;
         this.hpTxt.height = 50;
         this.hpTxt.x = this.playerMode.userID != MainManager.actorID ? 100 : 15;
         this.gainHpTxt = new TextField();
         this.gainHpTxt.autoSize = TextFieldAutoSize.CENTER;
         this.gainHpTxt.filters = [new GlowFilter(16776960,1,6,6,5)];
         this.gainHpTxt.width = 150;
         this.gainHpTxt.height = 50;
         this.gainHpTxt.x = this.playerMode.userID != MainManager.actorID ? 100 : 15;
         this.changeHpTxt = new TextField();
         this.changeHpTxt.autoSize = TextFieldAutoSize.CENTER;
         this.changeHpTxt.filters = [new GlowFilter(16777215,1,6,6,5)];
         this.changeHpTxt.width = 150;
         this.changeHpTxt.height = 50;
         this.changeHpTxt.x = this.playerMode.userID != MainManager.actorID ? 15 : 100;
      }
      
      private function defencePetPlay() : void
      {
         var _loc1_:MovieClip = this.defenceMC.getChildAt(0) as MovieClip;
         _loc1_.gotoAndPlay(2);
      }
      
      private function onMovieOver(param1:Event) : void
      {
         var propView:BaseFighterPropView;
         var isEnemy:Boolean = false;
         var event:Event = param1;
         this.animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_OVER,this.onMovieOver);
         this.animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_HIT,this.onMovieHit);
         this.animator.destroy();
         this.animator = null;
         this.defenceMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            var _loc3_:MovieClip = defenceMC.getChildAt(0) as MovieClip;
            if(Boolean(_loc3_))
            {
               defenceMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               _loc3_.gotoAndStop(1);
            }
         });
         if(Boolean(this.hpTxt))
         {
            this.hpTxt.y = 0;
         }
         if(SkillXMLInfo.getCategory(this.useSkillID) != 4)
         {
            if(this.value.isCrit)
            {
               this.hpMc = new HpMC();
               this.showCrisHp(this.hpMc["hpNum"],this.value.lostHP);
               isEnemy = this.playerMode.userID != MainManager.actorID;
               this.hpMc.x = isEnemy ? 420 : 210;
               this.hpMc.y = -80;
               this.defenceMC.parent.addChild(this.hpMc);
            }
            else
            {
               this.defenceMC.parent.addChild(this.hpTxt);
               if(this.value.atkTimes == 0)
               {
                  this.hpTxt.text = "MISS";
               }
               else
               {
                  this.hpTxt.text = "-" + this.value.lostHP;
               }
               this.hpTxt.setTextFormat(this.tf);
            }
         }
         else if(this.value.atkTimes == 0)
         {
            this.defenceMC.parent.addChild(this.hpTxt);
            this.hpTxt.text = "MISS";
            this.hpTxt.setTextFormat(this.tf);
         }
         if(this.value.gainHP != 0)
         {
            if(!this.gainHpTxt)
            {
               return;
            }
            this.gainHpTxt.y = 0;
            if(this.value.gainHP > 0)
            {
               this.gainHpTxt.text = "+" + this.value.gainHP.toString();
               this.gainHpTxt.setTextFormat(this.tf2);
            }
            else
            {
               this.gainHpTxt.text = this.value.gainHP.toString();
               this.gainHpTxt.setTextFormat(this.tf);
            }
            if(Boolean(this.attackMC.parent))
            {
               this.attackMC.parent.addChild(this.gainHpTxt);
            }
         }
         TweenLite.to(this.hpTxt,0.5,{"y":-30});
         TweenLite.to(this.gainHpTxt,0.5,{"y":-30});
         PetFightEntry.showEmotion(this.value);
         propView = this.playerMode.propView;
         propView.upPetPropIcon(this.value);
         this.timer = new Timer(1500,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.closeTxt);
         this.timer.start();
         dispatchEvent(new PetFightEvent(PetFightEvent.LOST_HP,this.lostHp));
         dispatchEvent(new PetFightEvent(PetFightEvent.GAIN_HP,this.gainHp,this.dispatchRemainHp));
      }
      
      public function showCrisHp(param1:MovieClip, param2:uint, param3:uint = 0, param4:Boolean = false) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:uint = param3 * 10;
         var _loc7_:Array = param2.toString().split("").reverse();
         _loc5_ = 0;
         while(param1["num_" + _loc5_] != null)
         {
            param1["num_" + _loc5_].gotoAndStop(1 + _loc6_);
            param1["num_" + _loc5_].visible = param4;
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc7_.length)
         {
            if(_loc7_[_loc5_] != undefined)
            {
               if(Boolean(param1["num_" + _loc5_]))
               {
                  param1["num_" + _loc5_].visible = true;
                  param1["num_" + _loc5_].gotoAndStop(uint(_loc7_[_loc5_]) + 1 + _loc6_);
               }
            }
            _loc5_++;
         }
         (param1["negative"] as MovieClip).x = -16 + (5 - _loc7_.length) * 65;
      }
      
      private function skillMoviePlay() : void
      {
         this.attackMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            subMC = attackMC.getChildAt(0) as MovieClip;
            if(Boolean(subMC))
            {
               attackMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               subMC.gotoAndPlay(2);
               attackMC.addEventListener(Event.ENTER_FRAME,petPlay);
               dispatchEvent(new Event(MOVIE_START));
            }
         });
      }
      
      private function closeChangeTxt(param1:TimerEvent) : void
      {
         DisplayUtil.removeForParent(this.changeHpTxt);
      }
      
      private function onMovieHit(param1:Event) : void
      {
         this.defenceMC.gotoAndStop("hited");
         setTimeout(this.defencePetPlay,200);
      }
      
      private function closeTxt(param1:TimerEvent) : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER,this.closeTxt);
         this.timer.stop();
         this.timer = null;
         dispatchEvent(new Event(MOVIE_OVER));
         if(Boolean(this.hpTxt))
         {
            DisplayUtil.removeForParent(this.hpTxt);
         }
         if(Boolean(this.hpMc))
         {
            DisplayUtil.removeForParent(this.hpMc);
         }
         if(Boolean(this.gainHpTxt))
         {
            DisplayUtil.removeForParent(this.gainHpTxt);
         }
      }
      
      private function petPlay(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:MovieClip = null;
         var _loc4_:Point = null;
         if(this.subMC.hit == 1)
         {
            this.attackMC.removeEventListener(Event.ENTER_FRAME,this.petPlay);
            _loc2_ = [];
            _loc3_ = SkillAssetsManager.getInstance().getAssetsByID(this.useSkillID);
            _loc4_ = this.attackMC.localToGlobal(new Point());
            _loc3_.x = _loc4_.x;
            _loc3_.y = _loc4_.y;
            _loc3_.scaleX = this.attackMC.scaleX;
            this.attackMC.parent.parent.addChild(_loc3_);
            this.animator = new BaseAnimatorCon(this.useSkillID,_loc3_);
            this.animator.addEventListener(BaseAnimatorCon.ON_MOVIE_OVER,this.onMovieOver);
            this.animator.addEventListener(BaseAnimatorCon.ON_MOVIE_HIT,this.onMovieHit);
            this.animator.playMovie();
            this.subMC.hit = 0;
         }
      }
      
      public function showChangeTxt(param1:int) : void
      {
         var _loc2_:Timer = null;
         if(param1 != 0)
         {
            this.changeHpTxt.y = 0;
            if(param1 > 0)
            {
               this.changeHpTxt.text = "+" + param1.toString();
            }
            else
            {
               this.changeHpTxt.text = param1.toString();
            }
            this.changeHpTxt.setTextFormat(this.tf3);
            this.attackMC.parent.addChild(this.changeHpTxt);
            TweenLite.to(this.changeHpTxt,0.3,{"y":-30});
            _loc2_ = new Timer(1500,1);
            _loc2_.addEventListener(TimerEvent.TIMER,this.closeChangeTxt);
            _loc2_.start();
         }
      }
      
      public function destroy() : void
      {
         this.subMC = null;
         this.attackMC = null;
         this.defenceMC = null;
         DisplayUtil.removeForParent(this.hpTxt);
         this.hpTxt = null;
         DisplayUtil.removeForParent(this.gainHpTxt);
         this.gainHpTxt = null;
         DisplayUtil.removeForParent(this.changeHpTxt);
         this.changeHpTxt = null;
         if(Boolean(this.animator))
         {
            this.animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_OVER,this.onMovieOver);
            this.animator.removeEventListener(BaseAnimatorCon.ON_MOVIE_HIT,this.onMovieHit);
            this.animator.destroy();
         }
         this.animator = null;
      }
      
      private function dispatchRemainHp() : void
      {
         dispatchEvent(new PetFightEvent(PetFightEvent.REMAIN_HP,this.remainHp));
      }
      
      public function action(param1:AttackValue) : void
      {
         this.value = param1;
         this.attackMC = this.playerMode.petWin.petMC;
         this.defenceMC = this.playerMode.enemyMode.petWin.petMC;
         this.lostHp = param1.lostHP;
         this.gainHp = param1.gainHP;
         this.remainHp = param1.remainHP;
         if(param1.skillID == 0)
         {
            this.dispatchRemainHp();
            return;
         }
         this.useSkillID = param1.skillID;
         if(this.useSkillID == 10825)
         {
            this.playLabel = "attack1";
         }
         else
         {
            this.playLabel = this.LABEL_ARRAY[SkillXMLInfo.getCategory(this.useSkillID)];
         }
         this.attackMC.gotoAndStop(this.playLabel);
         this.skillMoviePlay();
      }
   }
}

