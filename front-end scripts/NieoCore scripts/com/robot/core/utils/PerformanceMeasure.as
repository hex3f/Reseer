package com.robot.core.utils
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   
   public class PerformanceMeasure extends Sprite
   {
      
      private var _tf:TextField;
      
      private var _timer:Timer;
      
      private var _frameCount:int = 0;
      
      private var _fps:int;
      
      private var _gcCount:int;
      
      public function PerformanceMeasure(param1:Boolean = true, param2:Boolean = true)
      {
         super();
         if(param2)
         {
            this.initialize(param1);
         }
      }
      
      public function startGCCycle() : void
      {
         this._gcCount = 0;
         addEventListener(Event.ENTER_FRAME,this.doGC);
      }
      
      private function doGC(param1:Event) : void
      {
         System.gc();
         if(++this._gcCount > 1)
         {
            removeEventListener(Event.ENTER_FRAME,this.doGC);
            setTimeout(this.lastGC,40);
         }
      }
      
      private function lastGC() : void
      {
         System.gc();
      }
      
      private function initialize(param1:Boolean = true) : void
      {
         this._tf = new TextField();
         this._tf.text = "";
         this._tf.autoSize = TextFieldAutoSize.LEFT;
         this._tf.background = true;
         this._tf.backgroundColor = 0;
         this._tf.textColor = 16777215;
         this._tf.selectable = false;
         addChild(this._tf);
         if(param1)
         {
            buttonMode = true;
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         }
         this._timer = new Timer(1000);
         this._timer.addEventListener(TimerEvent.TIMER,this.runT);
         this._timer.start();
         addEventListener(Event.ENTER_FRAME,this.runEf);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         stopDrag();
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         startDrag(false);
      }
      
      private function runT(param1:TimerEvent) : void
      {
         this._fps = this._frameCount;
         this._frameCount = 0;
      }
      
      private function runEf(param1:Event) : void
      {
         this.mem();
         ++this._frameCount;
      }
      
      private function mem() : void
      {
         this._tf.text = this.format(System.totalMemory / 1024 / 1024) + " MB | " + this._fps + " FPS";
      }
      
      private function format(param1:Number) : String
      {
         var _loc2_:String = null;
         var _loc3_:Number = Math.pow(10,2);
         param1 = Math.round(param1 * _loc3_) / _loc3_;
         if(param1 <= 9)
         {
            _loc2_ = "0" + param1;
         }
         else
         {
            _loc2_ = param1.toString();
         }
         var _loc4_:String = _loc2_.split(".")[1];
         if(Boolean(_loc4_))
         {
            if(_loc4_.length < 2)
            {
               return _loc2_ + "0";
            }
            return _loc2_;
         }
         return _loc2_ + ".00";
      }
      
      public function finalize() : void
      {
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER,this.runT);
         this._timer = null;
         removeEventListener(Event.ENTER_FRAME,this.runEf);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
   }
}

