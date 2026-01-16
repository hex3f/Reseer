package com.robot.core.effect.shotBehavior
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.setTimeout;
   import org.taomee.utils.DisplayUtil;
   
   public class ShotEffect_143_4 implements IShotBehavior
   {
      
      private var modelMC:MovieClip;
      
      private var gunMC:MovieClip;
      
      private var bombMC:MovieClip;
      
      private var people:SpriteModel;
      
      private var armModel:PKArmModel;
      
      public function ShotEffect_143_4()
      {
         super();
         this.modelMC = ShotBehaviorManager.getMovieClip("shotEffect_143_4");
         this.bombMC = ShotBehaviorManager.getMovieClip("boomEffect_143_4");
         this.gunMC = ShotBehaviorManager.getMovieClip("gunEffect_143_4");
         this.modelMC["mc_1"].gotoAndStop(1);
         this.gunMC.gotoAndStop(1);
         this.bombMC.gotoAndStop(1);
      }
      
      public function shot(param1:PKArmModel, param2:SpriteModel) : void
      {
         this.armModel = param1;
         this.people = param2;
         var _loc3_:Rectangle = param1.getRect(param1);
         if(param1.isMirror)
         {
            this.modelMC.x = -_loc3_.x;
            this.modelMC.scaleX = -1;
         }
         else
         {
            this.modelMC.x = _loc3_.x;
            this.modelMC.scaleX = 1;
         }
         this.modelMC.y = _loc3_.y;
         param1.container.addChild(this.modelMC);
         param1.hideBmp();
         this.modelMC["mc_1"].gotoAndPlay(2);
         setTimeout(this.showGun,3600);
      }
      
      private function showGun() : void
      {
         var _loc1_:Point = this.people.localToGlobal(new Point());
         if(this.armModel.isMirror)
         {
            this.gunMC.x = _loc1_.x - 200;
            this.gunMC.scaleX = -1;
         }
         else
         {
            this.gunMC.x = _loc1_.x + 200;
            this.gunMC.scaleX = 1;
         }
         this.gunMC.y = _loc1_.y - 200;
         LevelManager.toolsLevel.addChild(this.gunMC);
         this.gunMC.gotoAndPlay(2);
         setTimeout(this.showBoom,3700);
      }
      
      private function showBoom() : void
      {
         this.armModel.showBmp();
         DisplayUtil.removeForParent(this.modelMC);
         DisplayUtil.removeForParent(this.gunMC);
         this.bombMC.x = this.people.x;
         this.bombMC.y = this.people.y;
         MapManager.currentMap.depthLevel.addChild(this.bombMC);
         this.bombMC.gotoAndPlay(2);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this.modelMC);
         DisplayUtil.removeForParent(this.gunMC);
         DisplayUtil.removeForParent(this.bombMC);
         this.modelMC = null;
         this.gunMC = null;
         this.bombMC = null;
         this.people = null;
         this.armModel = null;
      }
   }
}

