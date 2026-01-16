package com.robot.app.mapProcess.active
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.utils.Direction;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import gs.TweenLite;
   import org.taomee.manager.ResourceManager;
   
   public class RoutePetActive extends PetActive
   {
      
      private static const D_MAX:uint = 20;
      
      private static const pathList:Array = [[new Point(270,158),new Point(480,158),new Point(480,280),new Point(740,280),new Point(760,410)],[new Point(200,410),new Point(480,410),new Point(740,280),new Point(690,158),new Point(480,158)],[new Point(760,410),new Point(740,280),new Point(480,158),new Point(270,158),new Point(220,280)]];
      
      private var _curtPath:Array = [];
      
      private var _curtPoint:Point;
      
      private var _nextPoint:Point;
      
      private var _timer:Timer;
      
      public function RoutePetActive(param1:uint)
      {
         petID = param1;
         super();
      }
      
      override public function show() : void
      {
         this._timer = new Timer(3000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         if(!pet && Boolean(petID))
         {
            ResourceManager.getResource(ClientConfig.getPetSwfPath(petID),this.onLoadPet,"pet");
         }
         else
         {
            this.showPet();
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEntFrame);
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         if(Boolean(this._timer))
         {
            this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this._timer.stop();
            this._timer = null;
         }
      }
      
      private function onLoadPet(param1:MovieClip) : void
      {
         if(Boolean(param1))
         {
            pet = param1;
            pet.gotoAndStop("right");
            this.showPet();
         }
      }
      
      private function showPet() : void
      {
         this._curtPath = (pathList[Math.floor(Math.random() * pathList.length)] as Array).concat();
         this._curtPoint = this._curtPath.shift();
         if(Boolean(this._nextPoint))
         {
            TweenLite.to(pet,0.3,{
               "x":this._curtPoint.x,
               "y":this._curtPoint.y
            });
         }
         else
         {
            pet.x = this._curtPoint.x;
            pet.y = this._curtPoint.y;
         }
         MapManager.currentMap.depthLevel.addChild(pet);
         this._timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         pet.buttonMode = false;
         pet.removeEventListener(MouseEvent.CLICK,this.onClickPet);
         if(this._curtPath.length > 0)
         {
            this._nextPoint = this._curtPath.shift();
            pet.gotoAndStop(Direction.getStr(this._curtPoint,this._nextPoint));
            TweenLite.to(pet,0.3,{
               "x":this._nextPoint.x,
               "y":this._nextPoint.y,
               "onComplete":this.onMoveComplete
            });
         }
         else
         {
            this._timer.reset();
            this._timer.stop();
            this.showPet();
         }
      }
      
      private function onMoveComplete() : void
      {
         if(Boolean(pet))
         {
            pet.buttonMode = true;
            pet.addEventListener(MouseEvent.CLICK,this.onClickPet);
            this._curtPoint = this._nextPoint;
         }
      }
      
      private function onClickPet(param1:MouseEvent) : void
      {
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEntFrame);
         MainManager.actorModel.addEventListener(RobotEvent.WALK_END,this.onWalkEnd);
         MainManager.actorModel.walkAction(new Point(pet.x,pet.y));
      }
      
      private function onWalkEntFrame(param1:RobotEvent) : void
      {
         if(Point.distance(new Point(pet.x,pet.y),MainManager.actorModel.pos) < D_MAX)
         {
            FightInviteManager.fightWithBoss("野生精灵");
         }
      }
      
      private function onWalkEnd(param1:RobotEvent) : void
      {
         MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,this.onWalkEntFrame);
      }
   }
}

