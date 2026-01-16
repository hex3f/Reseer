package com.robot.core.effect.shotBehavior
{
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.utils.setTimeout;
   import org.taomee.utils.DisplayUtil;
   
   public class LaserBehavior implements IShotBehavior
   {
      
      private var laserMC:MovieClip;
      
      private var bombMC:MovieClip;
      
      public function LaserBehavior()
      {
         super();
         this.laserMC = ShotBehaviorManager.getMovieClip("laser");
         this.bombMC = ShotBehaviorManager.getMovieClip("bomb_2");
         this.laserMC.gotoAndStop(1);
         this.bombMC.gotoAndStop(1);
      }
      
      public function shot(param1:PKArmModel, param2:SpriteModel) : void
      {
         var armModel:PKArmModel = param1;
         var sprite:SpriteModel = param2;
         var rect:Rectangle = armModel.getRect(armModel);
         if(armModel.isMirror)
         {
            this.laserMC.x = -rect.x;
            this.laserMC.scaleX = -1;
         }
         else
         {
            this.laserMC.x = rect.x;
            this.laserMC.scaleX = 1;
         }
         this.laserMC.y = rect.y;
         armModel.container.addChild(this.laserMC);
         this.laserMC.gotoAndPlay(2);
         setTimeout(function():void
         {
            bombMC.x = sprite.x;
            bombMC.y = sprite.y;
            MapManager.currentMap.depthLevel.addChild(bombMC);
            bombMC.gotoAndPlay(2);
         },500);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this.laserMC);
         DisplayUtil.removeForParent(this.bombMC);
         this.laserMC = null;
         this.bombMC = null;
      }
   }
}

