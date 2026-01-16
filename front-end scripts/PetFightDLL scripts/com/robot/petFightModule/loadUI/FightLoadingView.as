package com.robot.petFightModule.loadUI
{
   import com.robot.core.info.fightInfo.FighetUserInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.MapModel;
   import com.robot.petFightModule.IFightLoading;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class FightLoadingView extends Sprite implements IFightLoading
   {
      
      private var _myMc:Sprite;
      
      private var _otherMc:Sprite;
      
      private var _mainMc:MovieClip;
      
      public function FightLoadingView(param1:Array)
      {
         var _loc2_:FighetUserInfo = null;
         super();
         this._mainMc = new Mx_Fight_Mc();
         this._myMc = this._mainMc["myMc"];
         this._otherMc = this._mainMc["otherMc"];
         this._myMc.visible = this._otherMc.visible = false;
         this._myMc["okMc"].visible = this._otherMc["okMc"].visible = false;
         this._myMc["nameTxt"].text = MainManager.actorInfo.nick;
         this.setMyPro(0);
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
         {
            this._otherMc["fMc"].gotoAndStop(1);
         }
         else
         {
            this._otherMc["fMc"].gotoAndStop(2);
         }
         var _loc3_:String = PetFightModel.enemyName;
         for each(_loc2_ in param1)
         {
            if(_loc2_.id != MainManager.actorID && _loc2_.nickName != "")
            {
               _loc3_ = _loc2_.nickName;
               PetFightModel.enemyName = _loc3_;
               break;
            }
         }
         this._otherMc["nameTxt"].text = _loc3_;
         if(PetFightModel.status != PetFightModel.FIGHT_WITH_PLAYER)
         {
            this.setOtherPro(100);
            this._otherMc["proTxt"].text = "";
            this._otherMc["okMc"].visible = true;
         }
         else
         {
            this._otherMc["proTxt"].text = "loading...";
         }
         var _loc4_:MapModel = MapManager.currentMap;
         this.addChild(this._mainMc);
         this._mainMc.x = -13.7;
         this._mainMc.y = -2.3;
         this.addEventListener(Event.ENTER_FRAME,this.onEHandler);
      }
      
      public function ok(param1:uint) : void
      {
         if(param1 == MainManager.actorID)
         {
            this._myMc["proTxt"].text = "";
            this._myMc["okMc"].visible = true;
            Sprite(this._myMc["proMc"]["mc"]).scaleX = 1;
         }
         else
         {
            this._otherMc["proTxt"].text = "";
            this._otherMc["okMc"].visible = true;
            Sprite(this._otherMc["proMc"]["mc"]).scaleX = 1;
         }
      }
      
      private function onEHandler(param1:Event) : void
      {
         if(this._mainMc.currentFrame == 25)
         {
            this._myMc.visible = this._otherMc.visible = true;
         }
         if(this._mainMc.currentFrame == this._mainMc.totalFrames)
         {
            this._mainMc.stop();
            this.removeEventListener(Event.ENTER_FRAME,this.onEHandler);
            this.dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function get sprite() : Sprite
      {
         return this;
      }
      
      public function setOtherPro(param1:uint) : void
      {
         this._otherMc["proTxt"].text = param1 + "%";
         Sprite(this._otherMc["proMc"]["mc"]).scaleX = param1 * 0.01;
      }
      
      public function setMyPro(param1:uint) : void
      {
         this._myMc["proTxt"].text = param1 + "%";
         Sprite(this._myMc["proMc"]["mc"]).scaleX = param1 * 0.01;
      }
      
      public function destroy() : void
      {
         this._mainMc = null;
         this._myMc = null;
         this._otherMc = null;
      }
   }
}

