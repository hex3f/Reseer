package com.robot.core.effect.shotBehavior
{
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import com.robot.core.mode.PKArmModel;
   import com.robot.core.mode.SpriteModel;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.setTimeout;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class ShotEffect_144_4 implements IShotBehavior
   {
      
      private var modelMC:MovieClip;
      
      private var bombMC:MovieClip;
      
      private var people:SpriteModel;
      
      private var armModel:PKArmModel;
      
      private var amc:Shape = new Shape();
      
      private var isP:Boolean = false;
      
      private var movPos:Point;
      
      private var startPos:Point;
      
      private var endPos:Point;
      
      private var speedPos:Point;
      
      private var color:uint = 65280;
      
      private var _speed:Number = 100;
      
      public function ShotEffect_144_4()
      {
         super();
         this.modelMC = ShotBehaviorManager.getMovieClip("shotEffect_144_4");
         this.bombMC = ShotBehaviorManager.getMovieClip("boomEffect_144");
         this.modelMC.gotoAndStop(1);
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
         this.modelMC.gotoAndPlay(2);
         setTimeout(this.showLight,2000);
      }
      
      private function showLight() : void
      {
         this.armModel.showBmp();
         DisplayUtil.removeForParent(this.modelMC);
         this.startPos = new Point(this.armModel.x,this.armModel.y - 105);
         this.endPos = new Point(this.people.x,this.people.y);
         if(Point.distance(this.startPos,this.endPos) < this._speed / 2)
         {
            return;
         }
         this.speedPos = GeomUtil.angleSpeed(this.startPos,this.endPos);
         this.speedPos.x *= this._speed;
         this.speedPos.y *= this._speed;
         this.amc = new Shape();
         this.amc.filters = [new GlowFilter(this.color)];
         MapManager.currentMap.depthLevel.addChild(this.amc);
         this.movPos = this.startPos.clone();
         this.amc.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      private function showBoom() : void
      {
         if(Boolean(this.amc))
         {
            this.amc.removeEventListener(Event.ENTER_FRAME,this.onEnter);
         }
         DisplayUtil.removeForParent(this.amc);
         this.bombMC.x = this.people.x;
         this.bombMC.y = this.people.y;
         MapManager.currentMap.depthLevel.addChild(this.bombMC);
         this.bombMC.gotoAndPlay(2);
         setTimeout(function():void
         {
            DisplayUtil.removeForParent(bombMC);
         },1500);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this.modelMC);
         DisplayUtil.removeForParent(this.bombMC);
         this.modelMC = null;
         this.bombMC = null;
         this.people = null;
         this.armModel = null;
         if(Boolean(this.amc))
         {
            this.amc.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            DisplayUtil.removeForParent(this.amc);
            this.amc = null;
         }
         this.movPos = null;
         this.speedPos = null;
      }
      
      private function onEnter(param1:Event) : void
      {
         this.amc.graphics.clear();
         if(Point.distance(this.movPos,this.endPos) < this._speed / 2)
         {
            if(this.isP)
            {
               this.amc.removeEventListener(Event.ENTER_FRAME,this.onEnter);
               DisplayUtil.removeForParent(this.amc);
               this.isP = false;
               return;
            }
            this.isP = true;
            this.movPos = this.startPos.clone();
            this.showBoom();
         }
         this.amc.graphics.lineStyle(4,16777215);
         if(this.isP)
         {
            this.amc.graphics.moveTo(this.endPos.x,this.endPos.y);
            this.amc.graphics.lineTo(this.movPos.x,this.movPos.y);
         }
         else
         {
            this.amc.graphics.moveTo(this.startPos.x,this.startPos.y);
            this.amc.graphics.lineTo(this.movPos.x,this.movPos.y);
         }
         this.movPos = this.movPos.subtract(this.speedPos);
      }
   }
}

