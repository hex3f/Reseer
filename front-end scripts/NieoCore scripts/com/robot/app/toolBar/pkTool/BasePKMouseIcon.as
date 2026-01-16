package com.robot.app.toolBar.pkTool
{
   import com.robot.core.config.xml.ShotDisXMLInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.ShotBehaviorManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class BasePKMouseIcon extends Sprite implements IPKMouseIcon
   {
      
      public static var forbidIcon:MovieClip;
      
      private static var array:Array = [];
      
      protected var _icon:Sprite;
      
      protected var _mouseIcon:Sprite;
      
      protected var shotDis:uint;
      
      protected var petDis:uint = 150;
      
      protected var outOfDistance:Boolean = false;
      
      private var _timer:Timer;
      
      private var _coolingTime:uint = 2;
      
      private var dark:Sprite;
      
      private var darkSize:uint = 51;
      
      public function BasePKMouseIcon()
      {
         super();
         this.buttonMode = true;
         this.shotDis = ShotDisXMLInfo.getClothDistance(MainManager.actorInfo.clothIDs);
         forbidIcon = ShotBehaviorManager.getMovieClip("pk_forbid_icon");
         array.push(this);
         this._icon = this.getIcon();
         this._mouseIcon = this.getMouseIcon();
         this._mouseIcon.addEventListener(MouseEvent.CLICK,this.clickWithMouseIcon);
         addChild(this.icon);
         this._timer = new Timer(1000,this._coolingTime);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComp);
         this.dark = new Sprite();
         this.dark.graphics.beginFill(0,0.5);
         this.dark.graphics.drawRoundRect(6,6,this.darkSize,this.darkSize,5,5);
         this.dark.graphics.endFill();
      }
      
      public function get sprite() : Sprite
      {
         return this;
      }
      
      protected function getIcon() : Sprite
      {
         return null;
      }
      
      protected function getMouseIcon() : Sprite
      {
         return null;
      }
      
      public function get icon() : Sprite
      {
         return this._icon;
      }
      
      public function get mouseIcon() : Sprite
      {
         return this._mouseIcon;
      }
      
      public function reset() : void
      {
      }
      
      protected function clickWithMouseIcon(param1:MouseEvent) : void
      {
         this.hide();
         MainManager.actorModel.hideRadius();
         if(!this.outOfDistance)
         {
            this.click();
            this._timer.reset();
            this._timer.start();
            this.mouseEnabled = false;
            this.mouseChildren = false;
            addChild(this.dark);
         }
      }
      
      public function click() : void
      {
      }
      
      public function move(param1:Point) : void
      {
      }
      
      public function show() : void
      {
         var _loc1_:IPKMouseIcon = null;
         for each(_loc1_ in array)
         {
            _loc1_.hide();
         }
         MainManager.getStage().addChild(this.mouseIcon);
         this.mouseIcon.startDrag(true);
         MainManager.getStage().addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         Mouse.hide();
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         this.move(new Point(param1.stageX,param1.stageY));
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(forbidIcon);
         DisplayUtil.removeForParent(this.mouseIcon);
         MainManager.getStage().removeEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
         Mouse.show();
      }
      
      public function destroy() : void
      {
         this.hide();
         this._icon = null;
         this._mouseIcon = null;
         ToolTipManager.remove(this);
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComp);
         this._timer = null;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = this.darkSize / this._coolingTime * this._timer.currentCount;
         this.dark.graphics.clear();
         this.dark.graphics.beginFill(0,0.5);
         this.dark.graphics.drawRoundRect(6,6 + _loc2_,this.darkSize,this.darkSize - _loc2_,5,5);
         this.dark.graphics.endFill();
      }
      
      private function onTimerComp(param1:TimerEvent) : void
      {
         this.mouseEnabled = true;
         this.mouseChildren = true;
         DisplayUtil.removeForParent(this.dark);
         this.dark.graphics.beginFill(0,0.5);
         this.dark.graphics.drawRoundRect(6,6,this.darkSize,this.darkSize,5,5);
         this.dark.graphics.endFill();
      }
   }
}

