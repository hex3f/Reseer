package com.robot.app.quickWord
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.taomee.utils.DisplayUtil;
   
   public class QuickWord
   {
      
      private var cls:Class = QuickWord_cls;
      
      private var xml:XML;
      
      private var menuContainer:Sprite;
      
      private var qw:QuickWordList;
      
      private var timer:Timer;
      
      public function QuickWord()
      {
         super();
         this.xml = new XML(new this.cls());
         this.timer = new Timer(500,1);
         this.timer.addEventListener(TimerEvent.TIMER,this.addStageListener);
      }
      
      public function show(param1:DisplayObject) : void
      {
         if(Boolean(this.qw))
         {
            this.hide();
            return;
         }
         var _loc2_:Point = param1.localToGlobal(new Point());
         this.qw = new QuickWordList(this.xml);
         this.qw.x = _loc2_.x - 50;
         this.qw.y = _loc2_.y - this.qw.height - 10;
         this.qw.addEventListener(Event.CLOSE,this.closeQw);
         LevelManager.toolsLevel.addChild(this.qw);
         this.timer.stop();
         this.timer.start();
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(this.qw);
         this.closeQw(null);
      }
      
      private function addStageListener(param1:TimerEvent) : void
      {
         MainManager.getStage().addEventListener(MouseEvent.CLICK,this.stageClick);
      }
      
      private function stageClick(param1:MouseEvent) : void
      {
         if(!this.qw.hitTestPoint(MainManager.getStage().mouseX,MainManager.getStage().mouseY,true))
         {
            this.qw.destroy();
         }
      }
      
      private function closeQw(param1:Event) : void
      {
         MainManager.getStage().removeEventListener(MouseEvent.CLICK,this.stageClick);
         this.qw.removeEventListener(Event.CLOSE,this.closeQw);
         this.qw = null;
         this.timer.stop();
      }
   }
}

