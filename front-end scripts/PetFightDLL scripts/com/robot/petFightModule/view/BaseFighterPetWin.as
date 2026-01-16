package com.robot.petFightModule.view
{
   import com.robot.app.task.control.*;
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.petFightModule.*;
   import com.robot.petFightModule.assetManager.*;
   import com.robot.petFightModule.control.*;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.utils.*;
   import org.taomee.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class BaseFighterPetWin extends Sprite
   {
      
      public static var itemID:uint;
      
      public static const WIN_WIDTH:uint = 180;
      
      public static const WIN_HEIGHT:uint = 280;
      
      public var petContainer:Sprite;
      
      protected var petID:uint;
      
      private var isBagFull:Boolean;
      
      private var _aniMcArr:Array;
      
      private var catchMC:MovieClip;
      
      protected var openningMovie:MovieClip;
      
      protected var _petMC:MovieClip;
      
      protected var filte:GlowFilter = new GlowFilter(3355443,0.9,3,3,3.1);
      
      public function BaseFighterPetWin()
      {
         super();
         this.petContainer = new Sprite();
         this.petContainer.graphics.beginFill(16777215,0);
         this.petContainer.graphics.drawRect(0,0,WIN_WIDTH,WIN_HEIGHT);
         addChild(this.petContainer);
         this.initContainerPos();
         this.initAniMcArr();
      }
      
      protected function setPetMC(param1:MovieClip) : void
      {
         DisplayUtil.removeAllChild(this.petContainer);
         param1.scaleX = -1;
         param1.x = WIN_WIDTH / 2;
         param1.y = 135;
         param1.gotoAndStop(1);
         param1.filters = [this.filte];
         this._petMC = param1;
         if(PetFightModel.defaultNpcID != FighterModeFactory.enemyMode.petID && PetFightModel.status == PetFightModel.FIGHT_WITH_NPC && PetFightModel.defaultNpcID != 0)
         {
            this.createOpenning();
         }
         else
         {
            this.petContainer.addChild(this._petMC);
            dispatchEvent(new PetFightEvent(PetFightEvent.ON_OPENNING));
         }
      }
      
      protected function initContainerPos() : void
      {
         this.petContainer.x = MainManager.getStageWidth() - WIN_WIDTH - 90;
         this.petContainer.y = 115;
      }
      
      public function destroy() : void
      {
         this._petMC = null;
         this.petContainer = null;
      }
      
      public function catchSuccess(param1:CatchPetInfo) : void
      {
         var data:CatchPetInfo = null;
         var mode:BaseFighterMode = null;
         data = null;
         data = param1;
         EventManager.dispatchEvent(new DynamicEvent(PetFightEvent.CATCH_SUCCESS,FighterModeFactory.enemyMode.petID));
         this.catchMC = null;
         if(!this.catchMC)
         {
            this.catchMC = this.getAniMcClass(BaseFighterPetWin.itemID);
            this.catchMC.x = 40;
            this.catchMC.y = -14;
         }
         this.catchMC.gotoAndPlay(2);
         mode = FighterModeFactory.enemyMode;
         mode.petWin.petContainer.addChild(this.catchMC);
         PetFightEntry.fighterCon.isCatch = true;
         setTimeout(function():void
         {
            if(PetManager.length < 6)
            {
               SocketConnection.send(CommandID.PET_RELEASE,data.catchTime,1);
               SocketConnection.send(CommandID.GET_PET_INFO,data.catchTime);
               isBagFull = false;
            }
            else
            {
               isBagFull = true;
               PetManager.addStorage(data.petID,data.catchTime);
            }
         },1500);
         setTimeout(this.afterCatchSuccess,4000);
         this.catchMC.addFrameScript(34,function():void
         {
            catchMC.addFrameScript(34,null);
            DisplayUtil.removeForParent(FighterModeFactory.enemyMode.petWin.petMC);
         });
      }
      
      private function initAniMcArr() : void
      {
         this._aniMcArr = new Array();
         this._aniMcArr.push(CatchMovie_C1);
         this._aniMcArr.push(CatchMovie_C2);
         this._aniMcArr.push(CatchMovie_C3);
         this._aniMcArr.push(CatchMovie_C4);
         this._aniMcArr.push(CatchMovie_C5);
         this._aniMcArr.push(CatchMovie_C6);
      }
      
      private function getAniMcClass(param1:int) : MovieClip
      {
         var _loc2_:int = 0;
         switch(param1)
         {
            case 300001:
               _loc2_ = 0;
               break;
            case 300002:
               _loc2_ = 1;
               break;
            case 300003:
               _loc2_ = 2;
               break;
            case 300004:
               _loc2_ = 3;
               break;
            case 300006:
               _loc2_ = 4;
               break;
            case 300009:
               _loc2_ = 5;
         }
         return new this._aniMcArr[_loc2_]();
      }
      
      private function checkIsCatchMovieOver() : void
      {
         this.catchMC.addFrameScript(109,function():void
         {
            catchMC.gotoAndStop(1);
            catchMC.addFrameScript(109,null);
            DisplayUtil.removeForParent(catchMC);
            if(Boolean(PetFightEntry.fighterCon.alarmSprite))
            {
               DisplayUtil.removeForParent(PetFightEntry.fighterCon.alarmSprite);
            }
            AbstractPetItemCategory.dispatchOnUsePetItem();
         });
      }
      
      private function createOpenning() : void
      {
         var mc:MovieClip = null;
         mc = null;
         mc = null;
         mc = PetAssetsManager.getInstance().getAssetsByID(PetFightModel.defaultNpcID);
         mc.x = BaseFighterPetWin.WIN_WIDTH / 2;
         mc.y = 145;
         mc.scaleX = -1;
         mc.gotoAndStop(1);
         mc.filters = [this.filte];
         this.petContainer.addChild(mc);
         if(!this.openningMovie)
         {
            this.openningMovie = new SpecialOpenningMovie();
            this.openningMovie.x = 0;
            this.openningMovie.y = 15;
         }
         this.petContainer.addChild(this.openningMovie);
         this.openningMovie.addEventListener(Event.ENTER_FRAME,function():void
         {
            if(!openningMovie)
            {
               return;
            }
            if(openningMovie.currentFrame == 22)
            {
               DisplayUtil.removeForParent(mc);
               petContainer.addChild(_petMC);
               petContainer.addChild(openningMovie);
            }
            else if(openningMovie.currentFrame == 52)
            {
               openningMovie.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(openningMovie);
               openningMovie = null;
               dispatchEvent(new PetFightEvent(PetFightEvent.ON_OPENNING));
            }
         });
      }
      
      public function update(param1:uint, param2:uint = 0) : void
      {
         this.petID = param1;
         var _loc3_:MovieClip = PetAssetsManager.getInstance().getAssetsByID(param2 == 0 ? int(param1) : int(param2));
         this.setPetMC(_loc3_);
      }
      
      public function get petMC() : MovieClip
      {
         return this._petMC;
      }
      
      public function catchFail() : void
      {
         var mode:BaseFighterMode = null;
         this.catchMC = null;
         if(!this.catchMC)
         {
            this.catchMC = this.getAniMcClass(BaseFighterPetWin.itemID);
            this.catchMC.x = 40;
            this.catchMC.y = -14;
         }
         this.catchMC.gotoAndPlay(2);
         mode = FighterModeFactory.enemyMode;
         mode.petWin.petContainer.addChild(this.catchMC);
         this.catchMC.addFrameScript(34,function():void
         {
            catchMC.gotoAndStop(1);
            catchMC.addFrameScript(34,null);
            catchMC.gotoAndPlay("fail");
            checkIsCatchMovieOver();
         });
      }
      
      private function afterCatchSuccess() : void
      {
         var sprite:Sprite = null;
         PetFightEntry.clear(null,true);
         if(!this.isBagFull)
         {
            sprite = Alarm.show("恭喜你，捕捉成功",function():void
            {
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.CATCH_PET));
               TaskController_90.catchPetEnd();
            });
         }
         else
         {
            sprite = Alarm.show("恭喜！捕捉成功，你可以在精灵仓库中找到它哦！",function():void
            {
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.CATCH_PET));
               TaskController_90.catchPetEnd();
            });
         }
         MainManager.getStage().addChild(sprite);
      }
   }
}

