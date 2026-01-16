package com.robot.core.mode.spriteModelAdditive
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.SpriteModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.teamPK.shotActive.AutoShotManager;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Timer;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class SpriteFreeze implements ISpriteModelAdditive
   {
      
      private var _model:SpriteModel;
      
      private var timer:Timer;
      
      private var mc:MovieClip;
      
      public function SpriteFreeze()
      {
         super();
         this.timer = new Timer(1000,15);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComp);
      }
      
      public function init() : void
      {
      }
      
      public function get model() : SpriteModel
      {
         return this._model;
      }
      
      public function set model(param1:SpriteModel) : void
      {
         this._model = param1;
      }
      
      public function show() : void
      {
         var _loc1_:ColorMatrixFilter = new ColorMatrixFilter([1,0,0,0,0,0,1,0,0,100,0,0,1,0,100,0,0,0,1,0]);
         if(this.model is BasePeoleModel)
         {
            (this.model as BasePeoleModel).skeleton.getBodyMC().filters = [_loc1_];
         }
         else
         {
            this.model.filters = [_loc1_];
         }
         this.timer.start();
         this.mc = ShotBehaviorManager.getMovieClip("pk_rest_mc");
         this.mc.gotoAndStop(1);
         this.mc.y = -this.model.height - 10;
         this.model.addChild(this.mc);
         ToolTipManager.add(this.mc,"原地整备15秒后你就能重新投入战斗了");
         if(this.model == MainManager.actorModel)
         {
            AutoShotManager.breakAuto();
         }
      }
      
      private function onTimerComp(param1:TimerEvent) : void
      {
         if(this.model == MainManager.actorModel)
         {
            SocketConnection.send(CommandID.TEAM_PK_UNFREEZE);
            AutoShotManager.openAuto();
         }
         this.model.removeAdditive(this);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = this.timer.currentCount / this.timer.repeatCount;
         this.mc.gotoAndStop(Math.floor(this.mc.totalFrames * _loc2_) + 1);
      }
      
      public function hide() : void
      {
      }
      
      public function destroy() : void
      {
         this.hide();
         if(this.model is BasePeoleModel)
         {
            (this.model as BasePeoleModel).skeleton.getBodyMC().filters = [];
         }
         else
         {
            this.model.filters = [];
         }
         this.model = null;
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
         ToolTipManager.remove(this.mc);
         DisplayUtil.removeForParent(this.mc);
         this.mc = null;
      }
   }
}

