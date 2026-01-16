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
   
   public class MissileBehavior implements IShotBehavior
   {
      
      private var missileMC:MovieClip;
      
      private var bombMC:MovieClip;
      
      public function MissileBehavior()
      {
         super();
         this.missileMC = ShotBehaviorManager.getMovieClip("missile");
         this.bombMC = ShotBehaviorManager.getMovieClip("bomb_1");
         this.missileMC.gotoAndStop(1);
         this.bombMC.gotoAndStop(1);
      }
      
      public function shot(param1:PKArmModel, param2:SpriteModel) : void
      {
         var armModel:PKArmModel = param1;
         var sprite:SpriteModel = param2;
         var rect:Rectangle = armModel.getRect(armModel);
         if(armModel.isMirror)
         {
            this.missileMC.x = -rect.x;
            this.missileMC.scaleX = -1;
         }
         else
         {
            this.missileMC.x = rect.x;
            this.missileMC.scaleX = 1;
         }
         this.missileMC.y = rect.y;
         armModel.container.addChild(this.missileMC);
         this.missileMC.gotoAndPlay(2);
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
         DisplayUtil.removeForParent(this.missileMC);
         DisplayUtil.removeForParent(this.bombMC);
         this.missileMC = null;
         this.bombMC = null;
      }
   }
}

