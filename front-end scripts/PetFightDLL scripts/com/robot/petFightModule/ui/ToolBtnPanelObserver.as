package com.robot.petFightModule.ui
{
   import com.robot.core.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.petFightModule.control.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.effect.*;
   
   public class ToolBtnPanelObserver extends BasePanelObserver implements IFightToolPanel
   {
      
      private var container:Sprite;
      
      private var pet_btn:MovieClip;
      
      private var btnArray:Array;
      
      private var escape_btn:MovieClip;
      
      private var fight_btn:MovieClip;
      
      private var item_btn:MovieClip;
      
      private var catch_btn:MovieClip;
      
      private var isCatch:Boolean = true;
      
      public function ToolBtnPanelObserver(param1:FightToolSubject, param2:Sprite)
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Array = null;
         var _loc5_:MovieClip = null;
         this.btnArray = [];
         super(param1);
         this.fight_btn = param2["fight_btn"];
         this.item_btn = param2["item_btn"];
         this.escape_btn = param2["escape_btn"];
         this.pet_btn = param2["pet_btn"];
         this.catch_btn = param2["catch_btn"];
         this.container = new Sprite();
         param2.addChild(this.container);
         this.btnArray.push(this.fight_btn,this.item_btn,this.escape_btn,this.pet_btn,this.catch_btn);
         for each(_loc3_ in this.btnArray)
         {
            _loc3_.mouseChildren = false;
            this.changeMCStatus(_loc3_,1);
            _loc3_.isClick = false;
            _loc3_.buttonMode = true;
            _loc3_.addEventListener(MouseEvent.MOUSE_OVER,this.toolBtnOverHandler);
            _loc3_.addEventListener(MouseEvent.MOUSE_OUT,this.toolBtnOutHandler);
            _loc3_.addEventListener(MouseEvent.CLICK,this.clickBtn);
            this.container.addChild(_loc3_);
         }
      }
      
      private function changeMCStatus(param1:MovieClip, param2:uint) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:uint = uint(param1.numChildren);
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = param1.getChildAt(_loc5_) as MovieClip;
            if(Boolean(_loc3_))
            {
               _loc3_.gotoAndStop(param2);
            }
            _loc5_++;
         }
      }
      
      private function resetOther() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.btnArray)
         {
            if(!this.isCatch && _loc1_ == this.catch_btn)
            {
               return;
            }
            _loc1_.isClick = false;
            _loc1_.buttonMode = true;
            _loc1_.mouseEnabled = true;
            this.changeMCStatus(_loc1_,1);
         }
      }
      
      override public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         super.destroy();
         for each(_loc1_ in this.btnArray)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.toolBtnOverHandler);
            _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.toolBtnOutHandler);
            _loc1_.removeEventListener(MouseEvent.CLICK,this.clickBtn);
         }
         this.fight_btn = null;
         this.item_btn = null;
         this.escape_btn = null;
         this.pet_btn = null;
         this.catch_btn = null;
         this.btnArray = [];
         this.btnArray = null;
      }
      
      public function open() : void
      {
         this.container.mouseChildren = true;
         this.container.filters = [];
      }
      
      public function close() : void
      {
         this.container.mouseChildren = false;
         this.container.filters = [ColorFilter.setGrayscale()];
      }
      
      private function toolBtnOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         this.changeMCStatus(_loc2_,2);
      }
      
      public function isCanCatch() : void
      {
         this.isCatch = FighterModeFactory.enemyMode.catchable;
         if(!this.isCatch)
         {
            this.catch_btn.filters = [ColorFilter.setGrayscale()];
            this.catch_btn = null;
         }
         else
         {
            this.catch_btn.filters = null;
         }
      }
      
      public function showFight() : void
      {
         this.resetOther();
         this.fight_btn.mouseEnabled = false;
         this.fight_btn.mouseChildren = false;
         this.changeMCStatus(this.fight_btn,2);
         this.fight_btn.isClick = true;
      }
      
      private function escape() : void
      {
         var mc:Sprite = null;
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
         {
            mc = Alarm.show("用户之间对战不能随便逃跑哦！");
            LevelManager.fightLevel.addChild(mc);
            this.escape_btn.filters = [ColorFilter.setGrayscale()];
         }
         else
         {
            LevelManager.root.mouseChildren = false;
            MainManager.getStage().addChild(Alert.show("你确定要逃离这次战斗吗？",function():void
            {
               LevelManager.root.mouseChildren = true;
               SocketConnection.send(CommandID.ESCAPE_FIGHT);
            },function():void
            {
               subject.showFightPanel();
               LevelManager.root.mouseChildren = true;
            }));
         }
      }
      
      public function showPet(param1:Boolean = false) : void
      {
         if(param1)
         {
            return;
         }
         this.resetOther();
         this.pet_btn.mouseEnabled = false;
         this.pet_btn.mouseChildren = false;
         this.changeMCStatus(this.pet_btn,2);
         this.pet_btn.isClick = true;
      }
      
      private function toolBtnOutHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(!_loc2_.isClick)
         {
            this.changeMCStatus(_loc2_,1);
         }
      }
      
      private function clickBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         switch(_loc2_)
         {
            case this.fight_btn:
               subject.showFightPanel();
               break;
            case this.item_btn:
               subject.showItemPanel();
               break;
            case this.catch_btn:
               subject.showCatchItemPanel();
               break;
            case this.pet_btn:
               if(PetFightModel.mode == PetFightModel.SINGLE_MODE)
               {
                  MainManager.getStage().addChild(Alarm.show("单挑模式下不能换宠哦"));
                  break;
               }
               subject.showPetPanel();
               break;
            case this.escape_btn:
               this.escape();
         }
      }
      
      public function showItem() : void
      {
         this.resetOther();
         this.item_btn.mouseEnabled = false;
         this.item_btn.mouseChildren = false;
         this.changeMCStatus(this.item_btn,2);
         this.item_btn.isClick = true;
      }
      
      public function showCatchItem() : void
      {
         this.resetOther();
         this.changeMCStatus(this.catch_btn,2);
         this.catch_btn.mouseEnabled = false;
         this.catch_btn.mouseChildren = false;
         this.catch_btn.isClick = true;
      }
   }
}

